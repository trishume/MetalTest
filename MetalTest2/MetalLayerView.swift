//
//  MetalLayerView.swift
//  MetalTest2
//
//  Created by Tristan Hume on 2019-06-19.
//  Copyright © 2019 Tristan Hume. All rights reserved.
//

import Cocoa

// Thanks to https://stackoverflow.com/questions/45375548/resizing-mtkview-scales-old-content-before-redraw
// for the recipe behind this, although I had to add presentsWithTransaction and the wait to make it glitch-free
class MetalLayerView: NSView, CALayerDelegate {
    var renderer : Renderer
    var metalLayer : CAMetalLayer!
    
    override init(frame: NSRect) {
        let _device = MTLCreateSystemDefaultDevice()!
        renderer = Renderer(pixelFormat: .bgra8Unorm, device: _device)
        
        super.init(frame: frame)
        
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .duringViewResize
        
        // This property only matters in the case of a rendering glitch, which shouldn't happen anymore
        // The .topLeft version makes glitches less noticeable for normal UIs,
        // while .scaleAxesIndependently matches what MTKView does and makes them very noticeable
//        self.layerContentsPlacement = .topLeft
        self.layerContentsPlacement = .scaleAxesIndependently
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func makeBackingLayer() -> CALayer {
        metalLayer = CAMetalLayer()
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.device = renderer.device
        metalLayer.delegate = self
        
        // If you're using the strategy of .topLeft placement and not presenting with transaction
        // to just make the glitches less visible instead of eliminating them, it can help to make
        // the background color the same as the background of your app, so the glitch artifacts
        // (solid color bands at the edge of the window) are less visible.
//        metalLayer.backgroundColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        metalLayer.allowsNextDrawableTimeout = false
        
        // these properties are crucial to resizing working
        metalLayer.autoresizingMask = CAAutoresizingMask(arrayLiteral: [.layerHeightSizable, .layerWidthSizable])
        metalLayer.needsDisplayOnBoundsChange = true
        metalLayer.presentsWithTransaction = true
        
        return metalLayer
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        renderer.viewportSize.x = UInt32(newSize.width)
        renderer.viewportSize.y = UInt32(newSize.height)
        // the conversion below is necessary for high DPI drawing
        metalLayer.drawableSize = convertToBacking(newSize)
        self.viewDidChangeBackingProperties()
    }
    
    // This will hopefully be called if the window moves between monitors of
    // different DPIs but I haven't tested this part
    override func viewDidChangeBackingProperties() {
        guard let window = self.window else { return }
        // This is necessary to render correctly on retina displays with the topLeft placement policy
        metalLayer.contentsScale = window.backingScaleFactor
    }
    
    func display(_ layer: CALayer) {
        // stress test with 100ms sleep, still works if this is uncommented
//        Thread.sleep(forTimeInterval: 0.1)
        
        let drawable = metalLayer.nextDrawable()!
        
        let passDescriptor = MTLRenderPassDescriptor()
        let colorAttachment = passDescriptor.colorAttachments[0]!
        colorAttachment.texture = drawable.texture
        colorAttachment.loadAction = .clear
        colorAttachment.storeAction = .store
        colorAttachment.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        let commandBuffer: MTLCommandBuffer = renderer.draw(passDescriptor: passDescriptor)!
        commandBuffer.commit()
        commandBuffer.waitUntilScheduled()
        drawable.present()
    }
}
