//
//  SimpleDrawingView.swift
//  Fractal Tree
//
//  Created by Noah Peeters on 09.07.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import UIKit

@IBDesignable
class SimpleDrawingView: UIView, UIGestureRecognizerDelegate {

    @IBInspectable
    /// The scale factor for the x axis
    var scaleX: CGFloat = 60 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    /// The scale factor for the y axis
    var scaleY: CGFloat = 60 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    /// The x coordinate of the center point
    var centerX: CGFloat = 0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    /// The y coordinate of the center point
    var centerY: CGFloat = 0 { didSet { setNeedsDisplay() } }
    
    
    //User interaction
    @IBInspectable
    /// Allows the user to scale the x axis
    var userXScalable: Bool = true
    
    @IBInspectable
    /// Allows the user to scale the y axis
    var userYScalable: Bool = true
    
    @IBInspectable
    /// Allows the user to scale the y axis without the x axis
    var userXOnlyScalable: Bool = true
    
    @IBInspectable
    /// Allows the user to scale the y axis without the x axis
    var userYOnlyScalable: Bool = true
    
    @IBInspectable
    /// Allows the user to move in the x direction
    var userXAxisTranslatable: Bool = true
    
    @IBInspectable
    /// Allows the user to move in the y direction
    var userYAxisTranslatable: Bool = true
    
    var visibleSize: CGSize {
        return CGSize(width: bounds.width / scaleX, height: bounds.height / scaleY)
    }
    
    var visibleBounds: CGRect {
        return CGRect(origin: screenToPoint(CGPoint(x: 0, y: 0)), size: visibleSize)
    }
    
    /// Centers the origin on the screen
    func centerOrigin() {
        centerX = 0
        centerY = 0
    }
    
    /// Equlizes the scale factor of the axis
    func equalizeAxis() {
        let scale = (scaleX + scaleY ) / 2
        scaleX = scale
        scaleY = scale
    }
    
    //MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    //MARK: Gesture Handlers
    
    @objc internal func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        if pinchRecognizer.state == .changed || pinchRecognizer.state == .ended {
            let pinchCenter = pinchRecognizer.location(in: self)
            let angle: CGFloat
            
            //calculate the angle of the two fingers
            if pinchRecognizer.numberOfTouches >= 2 {
                let firstPoint = pinchRecognizer.location(ofTouch: 0, in: self)
                let secondPoint = pinchRecognizer.location(ofTouch: 1, in: self)
                
                angle = abs(atan((secondPoint.y - firstPoint.y)/(secondPoint.x - firstPoint.x)))
            } else {
                angle = CGFloat.pi / 4
            }
            
            scale(
                factorX: userYOnlyScalable && angle > CGFloat.pi / 14 * 6 ? 1 : pinchRecognizer.scale,
                factorY: userXOnlyScalable && angle < CGFloat.pi / 14     ? 1 : pinchRecognizer.scale,
                at:      pinchCenter
            )
            
            //reset scale to get delta
            pinchRecognizer.scale = 1
        }
    }
    
    @objc internal func changeCenter(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        if panRecognizer.state == .changed || panRecognizer.state == .ended {
            let translation = panRecognizer.translation(in: self)
            if userXAxisTranslatable {
                centerX -= translation.x / scaleX
            }
            if userYAxisTranslatable {
                centerY += translation.y / scaleY
            }
            
            panRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)
        }
    }
    
    @objc internal func doubleTap(recognizedBy tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            let tapCenter = tapRecognizer.location(in: self)
            scale(factorX: 2, factorY: 2, at: tapCenter)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: Setup
    
    private func setup() {
        setupGestureRecognizers()
    }
    
    private func setupGestureRecognizers() {
        // translate
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(changeCenter(byReactingTo:)))
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
        
        // zoom
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(changeScale(byReactingTo:)))
        pinchGestureRecognizer.delegate = self
        self.addGestureRecognizer(pinchGestureRecognizer)
        
        // double tap to zoom
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap(recognizedBy:)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //MARK: Private
    
    /// Converts a x coordinate of a virtual point to the point on screen
    ///
    /// - Parameter x: The input coordinate
    /// - Returns: The x coordinate on the screen
    open func xPointToScreen(_ x: CGFloat) -> CGFloat {
        return bounds.midX + (x - centerX) * scaleX
    }
    
    open func yPointToScreen(_ y: CGFloat) -> CGFloat {
        return bounds.midY - (y - centerY) * scaleY
    }
    
    open func pointToScreen(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: xPointToScreen(point.x), y: yPointToScreen(point.y))
    }
    
    open func pointToScreen(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: xPointToScreen(x), y: yPointToScreen(y))
    }
    
    open func xScreenToPoint(_ x: CGFloat) -> CGFloat {
        return (x - bounds.midX) / scaleX + centerX
    }
    
    open func yScreenToPoint(_ y: CGFloat) -> CGFloat {
        return (y - bounds.midY) / scaleY - centerY
    }
    
    open func screenToPoint(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: xScreenToPoint(point.x), y: yScreenToPoint(point.y))
    }
    
    open func screenToPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: xScreenToPoint(x), y: yScreenToPoint(y))
    }
    
    open func scale(factorX: CGFloat, factorY: CGFloat, at: CGPoint) {
        if userXScalable {
            // update center
            let distance = bounds.midX - at.x
            centerX += distance / (scaleX * factorX) - distance / scaleX
            
            scaleX *= factorX
        }
        if userYScalable {
            // update center
            let distance = bounds.midY - at.y
            centerY -= distance / (scaleY * factorY) - distance / scaleY
            scaleY *= factorY
        }
    }
    
    override func draw(_ rect: CGRect) {
        //placeholder content
        
        UIColor.black.set()
        
        let x = UIBezierPath()
        
        x.move(to: pointToScreen(x: -1, y: 1))
        x.addLine(to: pointToScreen(x: 1, y: -1))
        
        x.move(to: pointToScreen(x: -1, y: -1))
        x.addLine(to: pointToScreen(x: 1, y: 1))
        x.stroke()
    }
}
