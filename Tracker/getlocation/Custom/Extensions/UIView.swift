//
//  UIView.swift
//  getlocation
//
//  Created by Олег Комаристый on 07.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func makeScreenshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { (context) in
            self.layer.render(in: context.cgContext)
        }
    }

    func installShadow(cornerRadiuis: Int, color: UIColor, offset: CGSize, opacity: CGFloat) {
        layer.cornerRadius = 2
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.45
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shadowRadius = 1.0
    }
}
