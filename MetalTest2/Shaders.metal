//
//  Shaders.metal
//  MetalTest2
//
//  Created by Tristan Hume on 2019-06-19.
//  Copyright © 2019 Tristan Hume. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
struct VertexIn {
    packed_float3 position;
    packed_float3 color;
};
struct VertexOut {
    float4 position [[position]];
    float4 color;
};
vertex VertexOut vertex_main(device const VertexIn *vertices [[buffer(0)]],
                             constant vector_uint2 *viewportSizePointer [[buffer(1)]],
                             uint vertexID [[vertex_id]]) {
    VertexOut out;
    // Index into the array of positions to get the current vertex.
    // The positions are specified in pixel dimensions (i.e. a value of 100
    // is 100 pixels from the origin).
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    // Get the viewport size and cast to float.
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    // hacky way of doing things differently for different vertices
    pixelSpacePosition -= (viewportSize / 2.0) - 25.0;
    
    if(vertices[vertexID].position.x == -1.0) {
        pixelSpacePosition.x = (viewportSize.x / 2.0) - 25.0;
    }
    
    
    // To convert from positions in pixel space to positions in clip-space,
    //  divide the pixel coordinates by half the size of the viewport.
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    // Pass the input color directly to the rasterizer.
    out.color = float4(vertices[vertexID].color, 1.0);
    return out;
}
fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
    }
