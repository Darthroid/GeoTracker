//
//  CardView.swift
//  getlocation
//
//  Created by Oleg Komaristy on 27.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class CardView: UIView {
    
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    var shadowColor: CGColor? {
        get {
            return layer.shadowColor
        }
        set {
            layer.shadowColor = newValue
        }
    }

    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        
        if #available(iOS 12, *), traitCollection.userInterfaceStyle == .dark {
            layer.shadowColor = nil
            layer.shadowPath = nil
        } else {
            let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            
            layer.masksToBounds = false
            layer.shadowColor = shadowColor
            layer.shadowOffset = CGSize(width: shadowOffset.width, height: shadowOffset.height);
            layer.shadowOpacity = shadowOpacity
            layer.shadowPath = shadowPath.cgPath
        }
    }

}
