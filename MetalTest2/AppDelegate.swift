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
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(contentRect: NSMakeRect(10, 10, 600, 600), styleMask: [.titled, .resizable, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.makeKeyAndOrderFront(nil)
        window.delegate = self
        
        let frame = NSRect(origin: CGPoint.zero, size: window.frame.size)
        let stack = NSStackView(views: [
            MetalView(frame: frame),
            CocoaView()
        ])
        stack.orientation = .vertical
        stack.distribution = .fillEqually
        
        window.contentView = stack
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
