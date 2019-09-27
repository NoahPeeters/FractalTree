//
//  TreeFractalView.swift
//  Fractal Tree
//
//  Created by Noah Peeters on 09.07.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import UIKit

@IBDesignable
class TreeFractalView: SimpleDrawingView {

    @IBInspectable
    /// The length of the first line
    var initialLength: CGFloat = 1
    
    @IBInspectable
    /// The factor used to calculate the length of the next line
    var lengthFactor: CGFloat = 0.6
    
    @IBInspectable
    var angleLeft: CGFloat = -CGFloat.pi / 4
    
    @IBInspectable
    var angleRight: CGFloat = CGFloat.pi / 4
    
    @IBInspectable
    var depth: Int = 10
    
    private func recursion(tree: BezierTurtle, withLength length: CGFloat, remainingDepth: Int) {
        guard remainingDepth > 0 else {
            return
        }
        
        tree.move(byDistance: length)
        tree.rotate(byAngle: angleLeft)
        recursion(tree: tree, withLength: length * lengthFactor, remainingDepth: remainingDepth - 1)
        tree.rotate(byAngle: angleRight - angleLeft)
        recursion(tree: tree, withLength: length * lengthFactor, remainingDepth: remainingDepth - 1)
        tree.rotate(byAngle: -angleRight)
        tree.drawing = false
        tree.move(byDistance: -length)
        tree.drawing = true
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.black.set()
        
        let tree = BezierTurtle()
        tree.move(to: CGPoint(x: 0, y: 0))
        tree.rotate(byAngle: -CGFloat.pi/2)
        
        recursion(tree: tree, withLength: initialLength, remainingDepth: depth)

        tree.apply(CGAffineTransform(translationX: -centerX, y: centerY))
        tree.apply(CGAffineTransform(scaleX: scaleX, y: scaleY))
        tree.apply(CGAffineTransform(translationX: bounds.midX, y: bounds.midY))
        
        
        tree.stroke()
        
    }
}
