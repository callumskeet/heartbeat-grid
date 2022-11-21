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
    
    // MARK: - Drawing
    let gridLayer = CALayer()
    
    var gridSize: (width: Int, height: Int)!
    let squareSize: CGFloat = 128
    let pixelSize: CGFloat = 8
    
    override func draw(_ rect: NSRect) {
        let overflow = 2
        gridSize = (
            width: Int(ceil(rect.width / squareSize)) + overflow,
            height: Int(ceil(rect.height / squareSize)) + overflow
        )
        
        let backgroundGridLayer = createBackgroundGridLayer(invert: true) {
            let gradient: [CGColor] = [
                NSColor.systemMint.cgColor,
                NSColor.white.withAlphaComponent(0.2).cgColor,
                NSColor.white.withAlphaComponent(0.2).cgColor
            ]
            return self.SquareLayer(gradient: gradient)
        }
        
        let foregroundGridLayer = createBackgroundGridLayer(invert: false) {
            let gradient: [CGColor] = [
                CGColor(red: 50 / 255, green: 173 / 255, blue: 230 / 255, alpha: 1),
                NSColor.black.withAlphaComponent(0.05).cgColor,
                NSColor.black.withAlphaComponent(0.05).cgColor
            ]
            return self.BezelSquareLayer(gradient: gradient)
        }
        
        gridLayer.addSublayer(backgroundGridLayer)
        gridLayer.addSublayer(foregroundGridLayer)
        
        layer?.addSublayer(gridLayer)
    }
    
    private func SteppedTriangle(origin pathOrigin: NSPoint, steps: Int) -> CGPath {
        let path = NSBezierPath()
        path.move(to: pathOrigin)
        
        for _ in 0..<steps {
            path.relativeLine(to: NSPoint(x: 0, y: pixelSize))
            path.relativeLine(to: NSPoint(x: pixelSize, y: 0))
        }
        
        path.line(to: NSPoint(x: path.currentPoint.x, y: pathOrigin.y))
        path.line(to: pathOrigin)
        return path.cgPath
    }
    
    func SquareLayer(gradient: [CGColor]) -> CALayer {
        let squareLayer = CAShapeLayer()
        squareLayer.path = NSBezierPath(rect: NSRect(x: 0, y: 0, width: squareSize, height: squareSize)).cgPath
        squareLayer.fillColor = gradient[0]
        
        let groupLayer = CALayer()
        groupLayer.addSublayer(squareLayer)
        
        for (i, offset) in [3, 11].enumerated() {
            let gradientLayer = CAShapeLayer()
            let steps = Int(squareSize / pixelSize) - offset
            gradientLayer.path = SteppedTriangle(origin: NSPoint(x: pixelSize * CGFloat(offset), y: 0), steps: steps)
            gradientLayer.fillColor = gradient[i + 1]
            groupLayer.addSublayer(gradientLayer)
        }
        
        return groupLayer
    }
    
    func BezelSquareLayer(gradient: [CGColor]) -> CALayer {
        let squareLayer = CAShapeLayer()
        let square = NSRect(x: 0, y: 0, width: squareSize, height: squareSize).insetBy(dx: -pixelSize / 2, dy: -pixelSize / 2)
        squareLayer.path = NSBezierPath(rect: square).cgPath
        squareLayer.fillColor = gradient[0]
        
        let groupLayer = CALayer()
        groupLayer.addSublayer(squareLayer)
        
        for (i, offset) in [3, 11].enumerated() {
            let gradientLayer = CAShapeLayer()
            let steps = Int(squareSize / pixelSize) - offset
            gradientLayer.path = SteppedTriangle(origin: NSPoint(x: square.minX + pixelSize * CGFloat(offset), y: square.minY + pixelSize), steps: steps)
            gradientLayer.fillColor = gradient[i + 1]
            groupLayer.addSublayer(gradientLayer)
        }
        
        func drawBezel(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: CGColor) {
            let bezel = NSRect(x: x, y: y, width: width, height: height)
            let layer = CAShapeLayer()
            layer.path = NSBezierPath(rect: bezel).cgPath
            layer.fillColor = color
            groupLayer.addSublayer(layer)
        }
        
        let nwColor = NSColor.white.withAlphaComponent(0.6).cgColor
        let seColor = NSColor.black.withAlphaComponent(0.2).cgColor
        
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
        
        return groupLayer
    }
    
    func createBackgroundGridLayer(invert: Bool, _ draw: () -> CALayer) -> CAReplicatorLayer {
        let columnLayer = CAReplicatorLayer()
        columnLayer.instanceCount = gridSize.width / 2
        columnLayer.instanceTransform = CATransform3DMakeTranslation(squareSize * 2, 0, 0)
        
        let primaryRow = draw()
        let secondaryRow = draw()
        if (invert) {
            primaryRow.position = CGPoint(x: squareSize, y: 0)
            secondaryRow.position = CGPoint(x: 0, y: squareSize)
        } else {
            secondaryRow.position = CGPoint(x: squareSize, y: squareSize)
        }
        
        columnLayer.addSublayer(primaryRow)
        columnLayer.addSublayer(secondaryRow)
        
        let backgroundGridLayer = CAReplicatorLayer()
        backgroundGridLayer.instanceCount = gridSize.height / 2
        backgroundGridLayer.instanceTransform = CATransform3DMakeTranslation(0, squareSize * 2, -1)
        backgroundGridLayer.addSublayer(columnLayer)
        
        return backgroundGridLayer
    }
    
    // MARK: - Animation
    override func startAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.5
        animation.fromValue = [0, 0]
        animation.toValue = [-squareSize, -squareSize]
        animation.repeatCount = .infinity
        gridLayer.add(animation, forKey: "move")
    }
}

extension NSBezierPath {
    
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            
            switch type {
            case .moveTo:
                path.move(to: points[0])
                
            case .lineTo:
                path.addLine(to: points[0])
                
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
                
            case .closePath:
                path.closeSubpath()
                
            @unknown default:
                break
            }
        }
        return path
    }
}

