//
//  TrackerCell.swift
//  getlocation
//
//  Created by Oleg Komaristy on 22.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import UIKit
import MapKit

class TrackerCellSimple: UITableViewCell, CellConfigurable {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	func setup(viewModel: RowViewModel) {
		guard let trackerModel = viewModel as? TrackerViewModel else {
			assert(false)
			return
		}
		
		self.textLabel?.text = trackerModel.name
		self.detailTextLabel?.text = trackerModel.description
	}
}

class TrackerCell: UITableViewCell, CellConfigurable {

	
//    @IBOutlet weak var cardStackView: UIStackView!
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var routeImageView: UIImageView!
    @IBOutlet weak var trackerDescriptionWrapperView: UIView!
    @IBOutlet weak var trackerNameLabel: UILabel!
    @IBOutlet weak var trackerDescriptionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let imageCache = NSCache<NSString, UIImage>()
    private var snapshotter: MKMapSnapshotter?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setStyle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.routeImageView?.image = nil
        
        // Stop rendering snapshot if cell is going to be reused
        self.snapshotter?.cancel()
        
        self.activityIndicator?.stopAnimating()
    }
    
    private func setStyle() {   //TODO: remove shadow for dark appearance
        self.cardView.cornerRadius = 20.0
        self.cardView.shadowColor = UIColor.gray.cgColor
        self.cardView.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.cardView.shadowRadius = 6.0
        self.cardView.shadowOpacity = 0.4
        
        self.routeImageView?.layer.cornerRadius = 20
        self.trackerDescriptionWrapperView.layer.cornerRadius = 20
        
        if #available(iOS 11.0, *) {
            self.routeImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.trackerDescriptionWrapperView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        if #available(iOS 13, *) {
            activityIndicator.style = .large
        }
    }
	
	func setup(viewModel: RowViewModel) {
		guard let trackerModel = viewModel as? TrackerViewModel else {
			assert(false)
			return
		}
		
		self.trackerNameLabel.text = trackerModel.name
		self.trackerDescriptionLabel.text = trackerModel.description
		
		if let cachedImage = self.imageCache.object(forKey: (trackerModel.id) as NSString) {
            self.routeImageView.image = cachedImage
        } else {
			self.takeSnapShot(points: trackerModel.dataSource.data.value, id: trackerModel.id)
        }
	}

    private func takeSnapShot(points: [PointViewModel], id: String) {
        self.routeImageView?.image = nil
        let mapSnapshotOptions = MKMapSnapshotter.Options()

		let coordinates = points.map({ $0.toCLLocationCoordinates() })
		
        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
        let region = MKCoordinateRegion(polyLine.boundingMapRect)

        mapSnapshotOptions.region = region

        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale

        // Set the size of the image output.
        mapSnapshotOptions.size = self.routeImageView.bounds.size

        mapSnapshotOptions.showsBuildings = false
        mapSnapshotOptions.showsPointsOfInterest = false

        let snapshotter = MKMapSnapshotter(options: mapSnapshotOptions)
        self.snapshotter = snapshotter
        
        self.activityIndicator.startAnimating()
        
        snapshotter.start(with: .global(qos: .userInteractive)) { [weak self] snapshot, error in
            guard let snapshot = snapshot else {
				DispatchQueue.main.async {
					self?.activityIndicator.stopAnimating()
				}
                return
            }
            
            let finalImage = snapshot.drawPolyline(polyLine, color: UIColor.blue, lineWidth: 3)
            self?.imageCache.setObject(finalImage, forKey: id as NSString)
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.routeImageView.image = finalImage
            }
        }
    }

}
