//
//  MetalLayerView.swift
//  MetalTest2
//
//  Created by Tristan Hume on 2019-06-19.
//  Copyright © 2019 Tristan Hume. All rights reserved.
//

import Cocoa

class MetalLayerView: NSView, CALayerDelegate {
    var renderer : Renderer
    var metalLayer : CAMetalLayer!
    
    override init(frame: NSRect) {
        let _device = MTLCreateSystemDefaultDevice()!
        renderer = Renderer(pixelFormat: .bgra8Unorm, device: _device)
        
        super.init(frame: frame)
        
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .duringViewResize
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
        
        metalLayer.autoresizingMask = CAAutoresizingMask(arrayLiteral: [.layerHeightSizable, .layerWidthSizable])
        metalLayer.needsDisplayOnBoundsChange = true
        
        metalLayer.presentsWithTransaction = true
        
        return metalLayer
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        renderer.viewportSize.x = UInt32(newSize.width)
        renderer.viewportSize.y = UInt32(newSize.height)
        metalLayer.drawableSize = newSize
    }
    
    func display(_ layer: CALayer) {
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
