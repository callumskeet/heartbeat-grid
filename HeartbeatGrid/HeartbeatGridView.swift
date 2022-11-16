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
        squareCountX = frame.width / squareSize.width
        
        super.init(frame: frame, isPreview: isPreview)
    }
    
    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var squareCountX: CGFloat
    
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    var maxOffsetX: CGFloat = CGFloat(Int.max)
    var maxOffsetY: CGFloat = CGFloat(Int.max)
    
    let squareSize = CGSize(width: 128, height: 128)
    
    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        maxOffsetX = rect.width
        maxOffsetY = rect.height
        
        drawGrid(rect)
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        
        offsetX = (offsetX - 4).truncatingRemainder(dividingBy: maxOffsetX)
        offsetY = (offsetY - 4).truncatingRemainder(dividingBy: maxOffsetX)
        
        setNeedsDisplay(bounds)
    }
    
    private func drawBezel(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: NSColor) {
        let bezel = NSRect(x: x, y: y, width: width, height: height)
        
        color.setFill()
        bezel.fill()
    }
    
    private func drawSquare(_ rect: NSRect, _ x: CGFloat, _ y: CGFloat) {
        let isForgroundSquare = ((x + y) / squareSize.width).truncatingRemainder(dividingBy: 2).isZero
        
        let overflow: CGFloat = isForgroundSquare ? 6 : 0
        let overflowOffset = overflow / 2
        
        let square = NSRect(
            x: x - overflowOffset,
            y: y - overflowOffset,
            width: squareSize.width + overflow,
            height: squareSize.height + overflow
        )
        
        let color: NSColor = isForgroundSquare ? .systemCyan : .systemMint
        
        color.setFill()
        square.fill()
        
        if (isForgroundSquare) {
            let bezelSize = squareSize.width / 16
            let nwColor: NSColor = .systemBlue.withSystemEffect(.deepPressed).withAlphaComponent(0.9)
            let seColor: NSColor = .systemBlue.withSystemEffect(.pressed).withAlphaComponent(0.8)
            
            // Bottom
            drawBezel(
                x: x - overflowOffset,
                y: y - overflowOffset,
                width: squareSize.width + overflow,
                height: bezelSize + overflow,
                color: seColor
            )
            // Right
            drawBezel(
                x: x - bezelSize + squareSize.width - overflowOffset,
                y: y - overflowOffset,
                width: bezelSize + overflow,
                height: squareSize.height + overflow,
                color: seColor
            )
            // Left
            drawBezel(
                x: x - overflowOffset,
                y: y - overflowOffset,
                width: bezelSize + overflow,
                height: squareSize.height + overflow,
                color: nwColor
            )
            // Top
            drawBezel(
                x: x - overflowOffset,
                y: y - bezelSize + squareSize.height - overflowOffset,
                width: squareSize.width + overflow,
                height: bezelSize + overflow,
                color: nwColor
            )
        }
    }
    
    private func drawGrid(_ rect: NSRect) {
        for x in stride(from: 0, to: rect.width, by: squareSize.width) {
            for y in stride(from: 0, to: rect.width, by: squareSize.width) {
                let isForegroundSquare = ((x + y) / squareSize.width).truncatingRemainder(dividingBy: 2).isZero
                if (!isForegroundSquare) {
                    drawSquare(rect, x, y)
                }
            }
        }
        
        for x in stride(from: 0, to: rect.width, by: squareSize.width) {
            for y in stride(from: 0, to: rect.width, by: squareSize.width) {
                let isForegroundSquare = ((x + y) / squareSize.width).truncatingRemainder(dividingBy: 2).isZero
                if (isForegroundSquare) {
                    drawSquare(rect, x, y)
                }
            }
        }
    }
}
