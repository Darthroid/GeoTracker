//
//  TrackerDetailViewController.swift
//  getlocation
//
//  Created by Oleg Komaristy on 25.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import UIKit
import MapKit

class TrackerDetailViewController: UIViewController, Storyboarded {
	// MARK: - Outlets

    @IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var containerView: UIView!
    @IBOutlet weak var buttonsWrapperView: CardView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!

	// MARK: - public properties

	public var viewModel: TrackerViewModel?

    // MARK: - ViewController LifeCycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.drawOnMap()
        self.setupInterface()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.clearMap()
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "bottomContainer" {
			let bottomDetailController = segue.destination as? TrackerDetailBottomViewController
			bottomDetailController?.delegate = self
			bottomDetailController?.viewModel = self.viewModel
		}
	}

    // MARK: - User defined methods

    private func setupInterface() {
//		self.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//		self.navigationItem.leftItemsSupplementBackButton = true

        self.buttonsWrapperView.cornerRadius = 10.0
        self.buttonsWrapperView.shadowColor = UIColor.gray.cgColor
        self.buttonsWrapperView.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.buttonsWrapperView.shadowRadius = 6.0
        self.buttonsWrapperView.shadowOpacity = 0.4

        self.closeButton?.layer.cornerRadius = 10.0
        self.infoButton.layer.cornerRadius = 10.0

        if #available(iOS 11.0, *) {
            self.closeButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.infoButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }

    // MARK: - Actions methods

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func infoButtonTapped(_ sender: Any) {
        // TODO: map style switch
    }

}

// MARK: - MKMapViewDelegate methods

extension TrackerDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self) {
            // draw the track
            let polyLine = overlay
            let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)

            polyLineRenderer.strokeColor = UIColor.blue
            polyLineRenderer.lineWidth = 2.0
            return polyLineRenderer
        }
        return MKPolylineRenderer()
    }

    func centerMapOnLocation(location: CLLocation) {
		let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
												  latitudinalMeters: 1000 * 2.0,
												  longitudinalMeters: 1000 * 2.0)
        mapView?.setRegion(coordinateRegion, animated: true)
    }

    func drawOnMap() {
		guard let points = self.viewModel?.points.value else { return }

        self.clearMap()
		let coordinates = points.map({ $0.toCLLocationCoordinate })

        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)

        self.mapView?.addOverlay(polyLine)

        UIView.animate(withDuration: 1.5, animations: { [weak self]  in
			let overlays = self?.mapView?.overlays
            if let topOverlay = overlays?.first(where: { $0 is MKPolyline }) {
                if let rect = overlays?.reduce(topOverlay.boundingMapRect, { $0.union($1.boundingMapRect) }) {
                    let edgePadding = UIEdgeInsets(top: 100.0, left: 100.0, bottom: 100.0, right: 100.0)
                    self?.mapView?.setVisibleMapRect(rect, edgePadding: edgePadding, animated: true)
                }

                let startPin = MKPointAnnotation()
                let finishPin = MKPointAnnotation()

                if let startCoordinate = coordinates.first,
                    let finishCoordinate = coordinates.last {
                    startPin.coordinate = startCoordinate
                    finishPin.coordinate = finishCoordinate
                    startPin.title = "Start"
                    finishPin.title = "Finish"
                    self?.mapView?.addAnnotation(startPin)
                    self?.mapView?.addAnnotation(finishPin)
                }
            }
        })
    }

    func clearMap() {
        let overlays = self.mapView?.overlays
        let allAnnotations = self.mapView?.annotations
        self.mapView?.removeAnnotations(allAnnotations ?? [])
        self.mapView?.removeOverlays(overlays ?? [])
    }
}

// MARK: - TrackerDetailBottomDelegate methods

extension TrackerDetailViewController: TrackerDetailBottomDelegate {
	func didSelectPoint(_ point: PointViewModel) {
		let annotationsToRemove = self.mapView.annotations.filter({ $0 is CustomPointAnnotation })
		self.mapView.removeAnnotations(annotationsToRemove)

		let annotation = CustomPointAnnotation()
		annotation.coordinate = point.toCLLocationCoordinate
		annotation.title = point.dateString()
		annotation.subtitle = point.description
		annotation.id = point.id

		self.mapView.addAnnotation(annotation)
	}
}
