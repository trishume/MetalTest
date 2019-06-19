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
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    
    var viewportSize: simd_uint2 = vector2(0, 0)
    
    init(frame: NSRect) {
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice()!)
        self.delegate = self
        
        self.isPaused = true
        self.enableSetNeedsDisplay = true
        self.needsDisplay = true
        //        metalView.presentsWithTransaction = true
        
        commandQueue = device!.makeCommandQueue()
        do {
            let library = device!.makeDefaultLibrary()!
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.colorAttachments[0].pixelFormat = self.colorPixelFormat
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
            pipelineState = try device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create pipeline")
        }
        
        //        self.draw()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize.x = UInt32(size.width)
        viewportSize.y = UInt32(size.height)
        print("changed \(viewportSize)")
        //        view.draw()
        view.needsDisplay = true
    }
    
    func draw(in view: MTKView) {
        guard let _commandQueue = commandQueue else { return }
        guard let commandBuffer = _commandQueue.makeCommandBuffer() else { return }
        guard let passDescriptor = view.currentRenderPassDescriptor else { return }
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else { return }
        let vertexData: [Float] = [ 250, -250, 0, 1, 0, 0,
                                    -250, -250, 0, 0, 1, 0,
                                    0,  250, 0, 0, 0, 1 ]
        encoder.setVertexBytes(vertexData,
                               length: vertexData.count * MemoryLayout<Float>.stride,
                               index: 0)
        encoder.setVertexBytes(&viewportSize,
                               length: MemoryLayout<simd_uint2>.stride,
                               index: 1)
        encoder.setRenderPipelineState(pipelineState)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        print("draw \(viewportSize)")
        //        commandBuffer.waitUntilScheduled()
        //        view.currentDrawable!.present()
        //        commandBuffer.waitUntilCompleted()
    }
}
