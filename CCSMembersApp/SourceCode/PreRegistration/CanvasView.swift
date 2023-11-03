//
//  Canvas.swift
//  CCSMembersApp
//
//  Created by Divyesh Dabhi on 04/05/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//


import Foundation
import UIKit


struct Line {
    let strokeWidth: Float
    let color: UIColor
    var points: [CGPoint]
}

class CanvasView: UIView {

    // public function
    fileprivate var strokeColor = UIColor.black
    fileprivate var strokeWidth: Float = 1

    func setStrokeWidth(width: Float) {
        self.strokeWidth = width
    }

    func setStrokeColor(color: UIColor) {
        self.strokeColor = color
    }

    func undo() {
        _ = lines.popLast()
        setNeedsDisplay()
    }

    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }

    fileprivate var lines = [Line]()
    var isDraw : Bool = false

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }

        lines.forEach { (line) in
            context.setStrokeColor(line.color.cgColor)
            context.setLineWidth(CGFloat(line.strokeWidth))
            context.setLineCap(.round)
            self.isDraw = true
            for (i, p) in line.points.enumerated() {
                if i == 0 {
                    context.move(to: p)
                } else {
                    context.addLine(to: p)
                }
            }
            context.strokePath()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append(Line.init(strokeWidth: strokeWidth, color: strokeColor, points: []))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

