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
    let FRAME_RATE: TimeInterval = 1 / 120
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = FRAME_RATE
    }
    
    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    var gridSize: (width: Int, height: Int)!
    
    override func draw(_ rect: NSRect) {
        let overflow = 2
        gridSize = (
            width: Int(rect.width / squareSize) + overflow,
            height: Int(rect.height / squareSize) + overflow
        )
        
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
    
    // MARK: - Animation
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    
    let ANIMATION_SPEED: CGFloat = 1
    
    override func animateOneFrame() {
        super.animateOneFrame()
        
        offsetX = (offsetX - ANIMATION_SPEED).truncatingRemainder(dividingBy: squareSize)
        offsetY = (offsetY - ANIMATION_SPEED).truncatingRemainder(dividingBy: squareSize)
        
        setNeedsDisplay(bounds)
    }
    
    // MARK: - Drawing
    let squareSize: CGFloat = 64
    let pixelSize: CGFloat = 4
    
    private func drawSteppedTriangle(origin pathOrigin: NSPoint, steps: Int, color: NSColor) {
        let path = NSBezierPath()
        path.move(to: pathOrigin)

        for _ in 0..<steps {
            path.relativeLine(to: NSPoint(x: 0, y: pixelSize))
            path.relativeLine(to: NSPoint(x: pixelSize, y: 0))
        }
        
        path.line(to: NSPoint(x: path.currentPoint.x, y: pathOrigin.y))
        path.line(to: pathOrigin)
        color.setFill()
        path.fill()
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
        
        let sideUnits = Int(squareSize / pixelSize)
        drawSteppedTriangle(
            origin: NSPoint(x: square.minX + pixelSize * 2, y: square.minY),
            steps: sideUnits - 2,
            color: .white.withAlphaComponent(0.2)
        )

        drawSteppedTriangle(
            origin: NSPoint(x: square.minX + pixelSize * 10, y: square.minY),
            steps: sideUnits - 10,
            color: .white.withAlphaComponent(0.2)
        )
    }
    
    private func drawBezeledSquare(_ origin: NSPoint) -> Void {
        let inset: CGFloat = pixelSize / 2
        
        let square = NSRect(
            x: origin.x,
            y: origin.y,
            width: squareSize,
            height: squareSize
        ).insetBy(
            dx: -inset,
            dy: -inset
        )
        
        NSColor.systemCyan.setFill()
        square.fill()
        
        let nwColor: NSColor = .white.withAlphaComponent(0.6)
        let seColor: NSColor = .black.withAlphaComponent(0.2)
        
        func drawBezel(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: NSColor) {
            let bezel = NSRect(x: x, y: y, width: width, height: height)
            
            color.setFill()
            bezel.fill()
        }
        
        // Bottom
        drawBezel(
            x: square.origin.x,
            y: square.origin.y,
            width: square.width,
            height: pixelSize,
            color: seColor
        )
        // Right
        drawBezel(
            x: square.origin.x + square.width - pixelSize,
            y: square.origin.y,
            width: pixelSize,
            height: square.height,
            color: seColor
        )
        // Left
        drawBezel(
            x: square.origin.x,
            y: square.origin.y,
            width: pixelSize,
            height: square.height,
            color: nwColor
        )
        // Top
        drawBezel(
            x: square.origin.x,
            y: square.origin.y + square.height - pixelSize,
            width: square.width,
            height: pixelSize,
            color: nwColor
        )
        
        let sideUnits = Int(squareSize / pixelSize)
        drawSteppedTriangle(
            origin: NSPoint(x: square.minX + pixelSize * 3, y: square.minY + pixelSize),
            steps: sideUnits - 3,
            color: .black.withAlphaComponent(0.05)
        )

        drawSteppedTriangle(
            origin: NSPoint(x: square.minX + pixelSize * 11, y: square.minY + pixelSize),
            steps: sideUnits - 11,
            color: .black.withAlphaComponent(0.05)
        )
    }
    
    private func drawCheckerboard(draw: (_ origin: NSPoint, _ isLocationEven: Bool) -> Void) {
        func getIsLocationEven(_ row: Int, _ col: Int) -> Bool {
            (row + col).isMultiple(of: 2)
        }
        
        func getOrigin(_ row: Int, _ col: Int) -> NSPoint {
            let x = Double(row) * squareSize
            let y = Double(col) * squareSize
            return NSPoint(x: x + offsetX, y: y + offsetY)
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
