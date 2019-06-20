//
//  MetalView.swift
//  MetalTest2
//
//  Created by Tristan Hume on 2019-06-19.
//  Copyright © 2019 Tristan Hume. All rights reserved.
//

import Cocoa
import MetalKit

class MetalView: MTKView, MTKViewDelegate {
    var renderer : Renderer!
    
    init(frame: NSRect) {
        let _device = MTLCreateSystemDefaultDevice()!
        super.init(frame: frame, device: _device)
        self.delegate = self
        
        self.isPaused = true
        self.enableSetNeedsDisplay = true
        self.needsDisplay = true
        
        renderer = Renderer(pixelFormat: self.colorPixelFormat, device: _device)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let pointSize = view.convertFromBacking(size)
        renderer.viewportSize.x = UInt32(pointSize.width)
        renderer.viewportSize.y = UInt32(pointSize.height)
//        print("changed \(renderer.viewportSize)")
        //        view.draw()
        view.needsDisplay = true
    }
    
    func draw(in view: MTKView) {
        guard let passDescriptor = view.currentRenderPassDescriptor else { return }
        guard let commandBuffer = renderer.draw(passDescriptor: passDescriptor) else { return }
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
//        print("draw \(renderer.viewportSize)")
        //        commandBuffer.waitUntilScheduled()
        //        view.currentDrawable!.present()
        //        commandBuffer.waitUntilCompleted()
    }
}
