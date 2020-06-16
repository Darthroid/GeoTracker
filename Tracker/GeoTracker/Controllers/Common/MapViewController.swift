//
//  MapViewController.swift
//  GeoTracker
//
//  Created by Oleg Komaristy on 15.03.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, Storyboarded {
	// MARK: - Outlets

	@IBOutlet weak var mapView: MKMapView!

	// MARK: - VC life cycle

	override func viewDidLoad() {
        super.viewDidLoad()
		mapView.delegate = self
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}

	deinit {
		self.clearMap()
		self.mapView?.delegate = nil
		self.mapView = nil
	}

	// MARK: - User defined methods

    func centerMapOnLocation(location: CLLocation) {
		let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
												  latitudinalMeters: 1000 * 2.0,
												  longitudinalMeters: 1000 * 2.0)
        mapView?.setRegion(coordinateRegion, animated: true)
    }

    func clearMap() {
        let overlays = self.mapView?.overlays
        let allAnnotations = self.mapView?.annotations
        self.mapView?.removeAnnotations(allAnnotations ?? [])
        self.mapView?.removeOverlays(overlays ?? [])
    }

	/// Draws polyline on map from coordiantes.
	/// - Parameters:
	///   - coordinates: Coordinates array for drwaing polyline.
	///   - center: Boolean value indicating whether map needs to be centered on polyline.
	///   - animated: Boolean value indicating whether centering on polyline should be animated.
	func drawPolyline(with coordinates: [CLLocationCoordinate2D], isNeedToCenter: Bool = true, animated: Bool = true) {
		self.mapView.removeOverlays(self.mapView.overlays)
        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)

        self.mapView?.addOverlay(polyLine)

		guard isNeedToCenter else { return }

		let centerBlock = { [weak self] in
			let overlays = self?.mapView?.overlays
            if let topOverlay = overlays?.first(where: { $0 is MKPolyline }) {
                if let rect = overlays?.reduce(topOverlay.boundingMapRect, { $0.union($1.boundingMapRect) }) {
                    let edgePadding = UIEdgeInsets(top: 100.0, left: 100.0, bottom: 100.0, right: 100.0)
                    self?.mapView?.setVisibleMapRect(rect, edgePadding: edgePadding, animated: true)
                }
            }
		}

		if animated {
			UIView.animate(withDuration: 1.5, animations: {
				centerBlock()
			})
		} else {
			centerBlock()
		}
    }

	func addAnnotation(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
		let annoatation = MKPointAnnotation()
		annoatation.coordinate = coordinate
		annoatation.title = title
		annoatation.subtitle = subtitle

		self.mapView.addAnnotation(annoatation)
	}
}

// MARK: - MKMapViewDelegate methods

extension MapViewController: MKMapViewDelegate {

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		guard let polyline = overlay as? MKPolyline else {
			return MKOverlayRenderer(overlay: overlay)
		}
		let renderer = MKPolylineRenderer(polyline: polyline)
		renderer.strokeColor = .blue
		renderer.lineWidth = 4
		return renderer
	}
}
