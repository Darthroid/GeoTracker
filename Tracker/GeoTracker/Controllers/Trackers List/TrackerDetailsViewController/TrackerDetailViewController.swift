//
//  TrackerDetailViewController.swift
//  getlocation
//
//  Created by Oleg Komaristy on 25.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import UIKit

class TrackerDetailViewController: UIViewController, Storyboarded {
	// MARK: - Outlets

//    @IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var mapContainerView: UIView!
	@IBOutlet weak var tableContainerView: UIView!

	// MARK: - public properties

	public var viewModel: TrackerViewModel!

	// MARK: - private properties

	var mapController: MapViewController!
	var tableController: TrackerDetailBottomViewController!

    // MARK: - ViewController LifeCycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
		self.setupChildViewControllers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupInterface()
		self.drawTrackerRoute()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - User defined methods

	private func setupChildViewControllers() {
		addChild(mapController)
		addChild(tableController)

		mapController.didMove(toParent: self)
		tableController.didMove(toParent: self)

		self.mapContainerView.addSubview(mapController.view)
		self.tableContainerView.addSubview(tableController.view)

		self.mapController.view.frame = self.mapContainerView.bounds
		self.tableController.view.frame = self.tableContainerView.bounds

		tableController.delegate = self
	}

    private func setupInterface() {
		//
    }

	func drawTrackerRoute() {
		let coordinates = viewModel.points.value.map({ $0.toCLLocationCoordinate })
		self.mapController.drawPolyline(with: coordinates, isNeedToCenter: true, animated: true)

		if let startCoordinate = coordinates.first, let finishCoordinate = coordinates.last {
			self.mapController.addAnnotation(coordinate: startCoordinate, title: "Start")
			self.mapController.addAnnotation(coordinate: finishCoordinate, title: "Finish")
		}
	}

    // MARK: - Actions methods

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - TrackerDetailBottomDelegate methods

extension TrackerDetailViewController: TrackerDetailBottomDelegate {
	func didSelectPoint(_ point: PointViewModel) {
		let annotationsToRemove = self.mapController.mapView.annotations.filter({ $0 is CustomPointAnnotation })
		self.mapController.mapView.removeAnnotations(annotationsToRemove)

		let annotation = CustomPointAnnotation()
		annotation.coordinate = point.toCLLocationCoordinate
		annotation.title = point.dateString()
		annotation.subtitle = point.description
		annotation.id = point.id

		self.mapController.mapView.addAnnotation(annotation)
	}
}
