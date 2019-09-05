//
//  TrackerDetailViewController.swift
//  gpstracky
//
//  Created by Oleg Komaristy on 04.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TrackerDetailViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var tracker: Tracker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.clearMap()
    }
    
    @IBAction func changeMapStyle(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .hybrid
        }
    }
}

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
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 1000 * 2.0, longitudinalMeters: 1000 * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func drawOnMap() {
        guard let tracker = self.tracker else { return }
        
        self.clearMap()
        
        let coordinates = tracker.map({CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)})
        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        self.mapView.addOverlay(polyLine)
        
        UIView.animate(withDuration: 1.5, animations: { [weak self]  in
            if let topOverlay = self?.mapView.overlays.first(where: { $0 is MKPolyline }) {
                if let rect = self?.mapView.overlays.reduce(topOverlay.boundingMapRect, {$0.union($1.boundingMapRect)}) {
                    let edgePadding = UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0)
                    self?.mapView.setVisibleMapRect(rect, edgePadding: edgePadding, animated: true)
                }
               
                let startPin = MKPointAnnotation()
                let finishPin = MKPointAnnotation()
                
                if let startCoordinate = coordinates.first,
                    let finishCoordinate = coordinates.last {
                    startPin.coordinate = startCoordinate
                    finishPin.coordinate = finishCoordinate
                    startPin.title = "Start: \(DateManager.timestampToString(tracker.first?.timestamp))"
                    finishPin.title = "Finish: \(DateManager.timestampToString(tracker.last?.timestamp))"
                    self?.mapView.addAnnotation(startPin)
                    self?.mapView.addAnnotation(finishPin)
                }
            }
        })
    }
    
    func clearMap() {
        let overlays = self.mapView.overlays
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        self.mapView.removeOverlays(overlays)
    }
}

extension TrackerDetailViewController: TrackerSelectionDelegate {
    func trackerSelected(_ tracker: Tracker) {
        self.tracker = tracker
        self.drawOnMap()
    }
}
