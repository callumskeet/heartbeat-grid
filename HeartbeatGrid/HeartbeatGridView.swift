//
//  HeartbeatGridView.swift
//  HeartbeatGrid
//
//  Created by Callum A Skeet on 13/11/2022.
//

import Foundation
import ScreenSaver
import AppKit

class HeartbeatGridView: ScreenSaverView {
    
    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
    }
    
    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    var maxOffsetX: CGFloat = CGFloat(Int.max)
    var maxOffsetY: CGFloat = CGFloat(Int.max)
    
    let squareSize = NSSize(width: 64, height: 64)
    let gridSize = (width: 8, height: 6)
    
    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        maxOffsetX = rect.width
        maxOffsetY = rect.height
        
        drawGrid(rect)
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        
        offsetX = offsetX - 4
        offsetY = offsetY - 4
        
        setNeedsDisplay(bounds)
    }
    
    private func drawSquare(_ origin: NSPoint) {
        let square = NSRect(
            x: origin.x,
            y: origin.y,
            width: squareSize.width,
            height: squareSize.height
        )
        
        NSColor.systemMint.setFill()
        square.fill()
    }
    
    private func drawBezeledSquare(_ origin: NSPoint) -> Void {
        let overflow: CGFloat = 2
        let overflowOffset = overflow / 2
        
        let square = NSRect(
            x: origin.x - overflowOffset,
            y: origin.y - overflowOffset,
            width: squareSize.width + overflow,
            height: squareSize.height + overflow
        )
        
        NSColor.systemCyan.setFill()
        square.fill()
        
        let bezelSize = squareSize.width / 16
        let nwColor: NSColor = .init(white: 0.95, alpha: 0.8)
        let seColor: NSColor = .systemBlue.withSystemEffect(.pressed).withAlphaComponent(0.9)
        
        func drawBezel(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: NSColor) {
            let bezel = NSRect(x: x, y: y, width: width, height: height)
            
            color.setFill()
            bezel.fill()
        }
        
        // Bottom
        drawBezel(
            x: origin.x - overflowOffset,
            y: origin.y - overflowOffset,
            width: squareSize.width + overflow,
            height: bezelSize + overflow,
            color: seColor
        )
        // Right
        drawBezel(
            x: origin.x - bezelSize + squareSize.width - overflowOffset,
            y: origin.y - overflowOffset,
            width: bezelSize + overflow,
            height: squareSize.height + overflow,
            color: seColor
        )
        // Left
        drawBezel(
            x: origin.x - overflowOffset,
            y: origin.y - overflowOffset,
            width: bezelSize + overflow,
            height: squareSize.height + overflow,
            color: nwColor
        )
        // Top
        drawBezel(
            x: origin.x - overflowOffset,
            y: origin.y - bezelSize + squareSize.height - overflowOffset,
            width: squareSize.width + overflow,
            height: bezelSize + overflow,
            color: nwColor
        )
    }
    
    private func drawGrid(_ rect: NSRect) {
        func getIsForegroundSquare(_ x: Int, _ y: Int) -> Bool {
            (x + y).isMultiple(of: 2)
        }
        
        func getOrigin(_ x: Int, _ y: Int) -> NSPoint {
            NSPoint(x: Double(x) * squareSize.width, y: Double(y) * squareSize.height)
        }
        
        for x in 0..<gridSize.width {
            for y in 0..<gridSize.height {
                let origin = getOrigin(x, y)
                let isForgroundSquare = getIsForegroundSquare(x, y)
                
                if (!isForgroundSquare) {
                    drawSquare(origin)
                }
            }
        }
        
        for x in 0..<gridSize.width {
            for y in 0..<gridSize.height {
                let origin = getOrigin(x, y)
                let isForgroundSquare = getIsForegroundSquare(x, y)
                
                if (isForgroundSquare) {
                    drawBezeledSquare(origin)
                }
            }
        }
    }
}
