//
//  DTIActivityIndicatorView.swift
//
//  Created by dtissera on 12/08/2014.
//  Copyright (c) 2014 o--O--o. All rights reserved.
//

import UIKit
import QuartzCore
import Foundation

@IBDesignable
@objc
class DTIActivityIndicatorView: UIView {
    // warning unlike objc, we dont have TARGET_INTERFACE_BUILDER macro in swift !
    // this variable as the right value only after prepareForInterfaceBuilder()
    // is called
    // https://developer.apple.com/library/prerelease/ios/recipes/xcode_help-IB_objects_media/CreatingaLiveViewofaCustomObject.html
    // http://justabeech.com/2014/08/03/prepareforinterfacebuilder-and-property-observers/
    private var runningWithinInterfaceBuilder: Bool = false
    
    /** private properties */
    private var activityStarted: Bool = false
    
    private var currentAnimation: DTIAnimProtocol? = nil
    
    /** @IBInspectable properties */
    @IBInspectable var indicatorColor: UIColor = UIColor.whiteColor() {
        didSet {
            if (self.currentAnimation != nil) {
                self.currentAnimation!.needUpdateColor()
            }
        }
    }
    
    @IBInspectable var indicatorStyle: String = DTIIndicatorStyle.convInv(.defaultValue)
    
    /** ctor && ~ctor */
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        if (self.activityStarted) {
            self.stopActivity()
        }
    }

    /** private members */
    private func setUpAnimation() {
        let style = DTIIndicatorStyle(self.indicatorStyle)
        switch style {
        case .rotatingPane:currentAnimation = DTIAnimRotatingPlane(indicatorView: self)
        case .chasingDots:currentAnimation = DTIAnimChasingDots(indicatorView: self)
        }
        
        self.setUpColors()
    }
    
    private func setUpColors() {
        self.backgroundColor = UIColor.clearColor()
        
        if (self.currentAnimation != nil) {
            self.currentAnimation!.needUpdateColor()
        }
    }
    
    /** overrides */
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.runningWithinInterfaceBuilder = true
        
        setUpColors();
    }
    
    override func layoutSubviews() {
        if (self.currentAnimation != nil) {
            currentAnimation!.needLayoutSubviews()
        }
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if (self.runningWithinInterfaceBuilder) {
            let context = UIGraphicsGetCurrentContext()
            CGContextSaveGState(context)
            
            CGContextSetStrokeColorWithColor(context, self.indicatorColor.CGColor)
            let dashLengths:[CGFloat] = [2.0, 2.0]
            CGContextSetLineDash(context, 0.0, dashLengths, UInt(dashLengths.count))
            CGContextStrokeRect(context, self.bounds)
            
            CGContextRestoreGState(context)
        }
    }
    
    /** public members */
    func startActivity() {
        if (self.activityStarted) {
            return
        }
        
        self.activityStarted = true
        self.setUpAnimation()
        currentAnimation!.setUp()
        currentAnimation!.startActivity()
    }

    func stopActivity() {
        if (!self.activityStarted) {
            return
        }

        self.activityStarted = false;
        currentAnimation!.stopActivity()
    }
}