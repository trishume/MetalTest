//
//  Renderer.swift
//  MetalTest2
//
//  Created by Tristan Hume on 2019-06-19.
//  Copyright © 2019 Tristan Hume. All rights reserved.
//

import Cocoa
import MetalKit

class Renderer {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState!
    
    var viewportSize: simd_uint2 = vector2(0, 0)
    
    init(pixelFormat: MTLPixelFormat, device: MTLDevice) {
        self.device = device
        
        commandQueue = device.makeCommandQueue()!
        do {
            let library = device.makeDefaultLibrary()!
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create pipeline")
        }
    }
    
    func draw(passDescriptor: MTLRenderPassDescriptor) -> MTLCommandBuffer? {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return nil }
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else { return nil }
        let vertexData: [Float] = [ -1.0, 0, 0, 1, 0, 0,
                                    0, 0, 0, 1, 0, 0,
                                    125,  125, 0, 1, 0, 0 ]
        encoder.setVertexBytes(vertexData,
                               length: vertexData.count * MemoryLayout<Float>.stride,
                               index: 0)
        encoder.setVertexBytes(&viewportSize,
                               length: MemoryLayout<simd_uint2>.stride,
                               index: 1)
        encoder.setRenderPipelineState(pipelineState)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
        
        return commandBuffer
    }
}
