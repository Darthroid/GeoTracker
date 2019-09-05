//
//  ViewController.swift
//  gpstracky
//
//  Created by Олег Комаристый on 15.02.17.
//  Copyright © 2017 Darthroid. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var data: [String: [TrackerPoint]] = [:]
    var indexes = [String]()
    var dates = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        map.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    @objc func fetchJSON() {
        let urlString = "http://trackmygps.000webhostapp.com/index.php?action=select"
        Alamofire.request(urlString).responseJSON { (responseData) -> Void in
            if (responseData.result.value) != nil {
                let json = JSON(responseData.result.value!)
                self.parseJSON(json: json)
            } else {
                AlertManager.showError(title: "Error", message: "No response from API")
            }
        }
    }
    
    func parseJSON(json: JSON) {
        data.removeAll()
        for index in 0...json.count-1 {
            let item = json[index]
            if data[item["objectID"].stringValue] == nil {
                data[item["objectID"].stringValue] = []
            }
            
            data[item["objectID"].stringValue]?.append(TrackerPoint(latitude: item["latitude"].doubleValue, longitude: item["longitude"].doubleValue, date: item["date"].int64Value))
        }
        indexes = [String](data.keys)
        self.tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
//    func showError(message: String) {
//        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(ac, animated: true)
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coordinatesCell", for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = indexes[row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let row = indexPath.row
        let overlays = map.overlays
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        map.removeOverlays(overlays)
        drawOnMap(object: indexes[row])
    }
    
    @objc func refresh(sender: AnyObject) {
        performSelector(inBackground: #selector(fetchJSON), with: nil)
        refreshControl.endRefreshing()
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 1000 * 2.0, longitudinalMeters: 1000 * 2.0)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func drawOnMap(object: String) {
        var i = 0
        dates = Array(repeating: String(), count: (data["\(object)"]?.count)!)
        var locations: [CLLocationCoordinate2D] = Array(repeating: CLLocationCoordinate2D(), count: (data["\(object)"]?.count)!)
        for keys in data {
            if keys.key == object {
                for values in keys.value {
                    locations[i] = CLLocationCoordinate2D(latitude: values.latitude, longitude: values.longitude)
//                    dates[i] = values.timestamp
                    i+=1
                }
            }
        }
        dates = parseTimestamp(timestamp: dates)
        let polyLine = MKPolyline(coordinates: locations, count: locations.count)
        map.addOverlay(polyLine)
        
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            if let first = self.map.overlays.first {
                let rect = self.map.overlays.reduce(first.boundingMapRect, {$0.union($1.boundingMapRect)})
                self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
                let startPin = MKPointAnnotation()
                let finishPin = MKPointAnnotation()
                startPin.coordinate = locations[0]
                finishPin.coordinate = locations[locations.count-1]
                startPin.title = "Start: \(self.dates[0])"
                finishPin.title = "Finish: \(self.dates[self.dates.count-1])"
                self.map.addAnnotation(startPin)
                self.map.addAnnotation(finishPin)
            }
        })
    }
    
    func parseTimestamp(timestamp: [String]) -> [String] {
        for index in 0...dates.count-1 {
            let interval = TimeInterval(dates[index])
            let time = NSDate(timeIntervalSince1970: TimeInterval(interval!))
            dates[index] = String(describing: time)
        }
        return dates
    }
    
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
    
    @IBAction func changeMapStyle(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            map.mapType = .standard
        case 1:
            map.mapType = .satellite
        case 2:
            map.mapType = .hybrid
        default:
            map.mapType = .hybrid
        }
    }
    
}
