import Cocoa
import MetalKit

class MyApplication: NSApplication {
    let strongDelegate = AppDelegate()
    
    override init() {
        super.init()
        self.delegate = strongDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, MTKViewDelegate {
    var window: NSWindow!
    var metalView: MTKView!
    let device = MTLCreateSystemDefaultDevice()!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    
    var viewportSize: simd_uint2 = vector2(0, 0)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(contentRect: NSMakeRect(10, 10, 600, 600), styleMask: [.titled, .resizable, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.makeKeyAndOrderFront(nil)
        window.delegate = self
        
        metalView = MTKView(frame: NSRect(origin: CGPoint.zero, size: window.frame.size), device: device)
        metalView.delegate = self
        
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
        metalView.needsDisplay = true
//        metalView.presentsWithTransaction = true
        
        window.contentView = metalView
        commandQueue = device.makeCommandQueue()
        do {
            let library = device.makeDefaultLibrary()!
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create pipeline")
        }
        
        metalView.draw()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize.x = UInt32(size.width)
        viewportSize.y = UInt32(size.height)
        print("changed \(viewportSize)")
//        view.draw()
        metalView.needsDisplay = true
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
