//
//  BezierTurtle.swift
//  Fractal Tree
//
//  Created by Noah Peeters on 09.07.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import UIKit

class BezierTurtle: UIBezierPath {
    /// The current angle of the turtle
    var currentAngle: CGFloat = 0
    
    var drawing: Bool = true
 
    
    /// Rotates the turtle
    ///
    /// - Parameter angle: The angle to rotate
    func rotate(byAngle angle: CGFloat) {
        currentAngle += angle
    }
    
    
    /// Moves the turtle
    ///
    /// - Parameter distance: The distance to move; negative values to move backwards
    func move(byDistance distance: CGFloat) {
        let targetX = currentPoint.x + cos(currentAngle) * distance
        let targetY = currentPoint.y + sin(currentAngle) * distance

        let target = CGPoint(x: targetX, y: targetY)
        
        if drawing {
            addLine(to: target)
        } else {
            move(to: target)
        }
    }
}
