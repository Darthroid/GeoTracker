//
//  TrackerCell.swift
//  getlocation
//
//  Created by Oleg Komaristy on 22.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import UIKit
import MapKit

class TrackerCell: UITableViewCell {
    @IBOutlet weak var cardStackView: UIStackView!
    @IBOutlet weak var routeImageView: UIImageView!
    @IBOutlet weak var trackerDescriptionWrapperView: UIView!
    @IBOutlet weak var trackerNameLabel: UILabel!
    @IBOutlet weak var trackerDescriptionLabel: UILabel!
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.cardStackView.layer.cornerRadius = 15
        self.routeImageView?.layer.cornerRadius = 15
        self.trackerDescriptionWrapperView.layer.cornerRadius = 15
        
        if #available(iOS 11.0, *) {
            self.routeImageView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
            self.trackerDescriptionWrapperView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with tracker: Tracker) {
        self.trackerNameLabel.text = tracker.name
        self.trackerDescriptionLabel.text = "\(String(describing: tracker.points?.count ?? 0)) points"
        self.takeSnapShot(points: tracker.points, id: tracker.id)
    }
    
    private func takeSnapShot(points: Set<Point>?, id: String?) {

        
        let takeSnapshotBlock = {
            let mapSnapshotOptions = MKMapSnapshotter.Options()

            guard let coordinates = points?.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }) else { return }
            let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
            let region = MKCoordinateRegion(polyLine.boundingMapRect)

            mapSnapshotOptions.region = region

            // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
            mapSnapshotOptions.scale = UIScreen.main.scale

            // Set the size of the image output.
            mapSnapshotOptions.size = CGSize(width: self.routeImageView.bounds.size.width,
                                             height: self.routeImageView.bounds.size.height)

            mapSnapshotOptions.showsBuildings = false
            mapSnapshotOptions.showsPointsOfInterest = false

            let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)

            snapShotter.start(with: .global(qos: .userInteractive)) { [unowned self] snapshot, error in
                guard let snapshot = snapshot else {
                    return
                }
                
                let finalImage = snapshot.drawPolyline(polyLine, color: UIColor.blue, lineWidth: 3)
                self.imageCache.setObject(finalImage, forKey: (id ?? "") as NSString)
                self.routeImageView.image = finalImage
            }
        }
        
        
        if let cachedImage = self.imageCache.object(forKey: (id ?? "") as NSString) {
            self.routeImageView.image = cachedImage
        } else {
            takeSnapshotBlock()
        }
    }

}


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
