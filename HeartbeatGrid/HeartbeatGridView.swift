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
    
    let squareSize: CGFloat = 64
    let gridSize = (width: 8, height: 6)
    
    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        maxOffsetX = rect.width
        maxOffsetY = rect.height
        
        drawCheckerboard { [weak self] (origin, isForeground) in
            if (!isForeground) {
                self?.drawSquare(origin)
            }
        }
        
        drawCheckerboard { [weak self] (origin, isForeground) in
            if (isForeground) {
                self?.drawBezeledSquare(origin)
            }
        }
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        
        offsetX = offsetX - 1
        offsetY = offsetY - 1
        
        setNeedsDisplay(bounds)
    }
    
    private func drawSquare(_ origin: NSPoint) {
        let square = NSRect(
            x: origin.x,
            y: origin.y,
            width: squareSize,
            height: squareSize
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
            width: squareSize + overflow,
            height: squareSize + overflow
        )
        
        NSColor.systemCyan.setFill()
        square.fill()
        
        let bezelSize = squareSize / 16
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
            width: squareSize + overflow,
            height: bezelSize + overflow,
            color: seColor
        )
        // Right
        drawBezel(
            x: origin.x - bezelSize + squareSize - overflowOffset,
            y: origin.y - overflowOffset,
            width: bezelSize + overflow,
            height: squareSize + overflow,
            color: seColor
        )
        // Left
        drawBezel(
            x: origin.x - overflowOffset,
            y: origin.y - overflowOffset,
            width: bezelSize + overflow,
            height: squareSize + overflow,
            color: nwColor
        )
        // Top
        drawBezel(
            x: origin.x - overflowOffset,
            y: origin.y - bezelSize + squareSize - overflowOffset,
            width: squareSize + overflow,
            height: bezelSize + overflow,
            color: nwColor
        )
    }
    
    private func drawCheckerboard(draw: (_ origin: NSPoint, _ isLocationEven: Bool) -> Void) {
        func getIsLocationEven(_ row: Int, _ col: Int) -> Bool {
            (row + col).isMultiple(of: 2)
        }
        
        func getOrigin(_ row: Int, _ col: Int) -> NSPoint {
            let x = Double(row) * squareSize
            let y = Double(col) * squareSize
            return NSPoint(x: x, y: y)
        }
        
        for col in 0..<gridSize.width {
            for row in 0..<gridSize.height {
                let origin = getOrigin(col, row)
                let isEven = getIsLocationEven(col, row)
                draw(origin, isEven)
            }
        }
    }
}
