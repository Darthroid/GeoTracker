//
//  MKMapSnapshotter.swift
//  getlocation
//
//  Created by Oleg Komaristy on 24.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import Foundation
import MapKit

extension MKMapSnapshotter.Snapshot {

    func drawPolyline(_ polyline: MKPolyline, color: UIColor, lineWidth: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(self.image.size)
        let rectForImage = CGRect(x: 0, y: 0, width: self.image.size.width, height: self.image.size.height)

        // Draw map
        self.image.draw(in: rectForImage)

        var pointsToDraw = [CGPoint]()

        let points = polyline.points()
        var i = 0
        while (i < polyline.pointCount)  {
            let point = points[i]
            let pointCoord = point.coordinate
            let pointInSnapshot = self.point(for: pointCoord)
            pointsToDraw.append(pointInSnapshot)
            i += 1
        }

        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(lineWidth)

        for point in pointsToDraw {
            if (point == pointsToDraw.first) {
                context!.move(to: point)
            } else {
                context!.addLine(to: point)
            }
        }

        context?.setStrokeColor(color.cgColor)
        context?.strokePath()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
