//
//  CocoaView.swift
//  MetalTest2
//
//  Created by Tristan Hume on 2019-06-19.
//  Copyright © 2019 Tristan Hume. All rights reserved.
//

import Cocoa

class CocoaView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        NSColor.white.setFill()
        bounds.fill()
        
        NSColor.red.setFill()
        NSRect(x: 25, y: 25, width: 250, height: bounds.size.height - 50).fill()
    }
    
}
