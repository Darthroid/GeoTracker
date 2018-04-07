//
//  StartTrackingViewController.swift
//  getlocation
//
//  Created by Олег Комаристый on 01.04.2018.
//  Copyright © 2018 Darthroid. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import Alamofire

class StartTrackingViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var statusTextView: UITextView!
  @IBOutlet weak var finishTrackingButton: UIButton!

  let manager = CLLocationManager()
  var id: String?
  var updateFrequency: Double?
  weak var timer: Timer?
  var data: [NSManagedObject] = []
  var location: [CLLocation] = []
  let trackerData = TrackerData()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.delegate = self
    mapView.showsUserLocation = true

    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.delegate = self
    manager.requestAlwaysAuthorization()
    manager.allowsBackgroundLocationUpdates = true
    manager.startUpdatingLocation()
    self.observeTrackerData()
  }

  // MARK: - Observing coordinates from CLLocationManager

  func observeTrackerData() {
    timer = Timer.scheduledTimer(withTimeInterval: updateFrequency!, repeats: true) { (timer) in
      self.trackerData.id = self.id
      self.trackerData.latitude = self.manager.location?.coordinate.latitude
      self.trackerData.longitude = self.manager.location?.coordinate.longitude
      self.trackerData.timestamp = NSDate().timeIntervalSince1970
      print(self.trackerData.latitude!, self.trackerData.longitude!, self.trackerData.timestamp!)
      self.saveTrackerData()
    }
  }

  // MARK: - Saving observed data to CoreData

  func saveTrackerData() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

    let managedContext = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "Data", in: managedContext)!
    let dataToSave = NSManagedObject(entity: entity, insertInto: managedContext)

    dataToSave.setValue(trackerData.latitude, forKeyPath: "latitude")
    dataToSave.setValue(trackerData.longitude, forKey: "longitude")
    dataToSave.setValue(trackerData.id, forKey: "id")
    dataToSave.setValue(trackerData.timestamp, forKey: "timestamp")

    do {
      try managedContext.save()
      data.append(dataToSave)
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }

  // MARK: - Loading data from CoreData

  func loadTrackerData() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Data")

    do {
      self.data = try managedContext.fetch(fetchRequest)
      for alldata in self.data {
        self.sendTrackerData(lat: alldata.value(forKey: "latitude") as! Double, lon: alldata.value(forKey: "longitude") as! Double, id: alldata.value(forKey: "id") as! String, timestamp: alldata.value(forKey: "timestamp") as! Double)
      }
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }

  // MARK: - Sending all observed data to server

  func sendTrackerData(lat: Double, lon: Double, id: String, timestamp: Double) {
    let url = "http://trackmygps.000webhostapp.com/index.php?action=insert&latitude=\(lat)&longitude=\(lon)&objectID=\(id)&date=\(String(timestamp))"
    Alamofire.request(url)
  }

  // MARK: - Clearing all data from CoreData

  func clearSaveTrackerdData() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

    let managedContext = appDelegate.persistentContainer.viewContext
    let delAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Data"))

    do {
      try managedContext.execute(delAllReqVar)
    }
    catch {
      print(error)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    location.append(locations[0])
    statusTextView.text = String(describing: locations[0])
    let spanX = 0.007
    let spanY = 0.007
    let newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
    mapView.setRegion(newRegion, animated: true)

    if location.count > 1 {
      let sourceIndex = location.count - 1
      let destinationIndex = location.count - 2

      let c1 = location[sourceIndex].coordinate
      let c2 = location[destinationIndex].coordinate
      var a = [c1, c2]
      let polyline = MKPolyline(coordinates: &a, count: a.count)
      mapView.add(polyline)
    }
  }

  func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {

    if overlay is MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      polylineRenderer.strokeColor = UIColor.blue
      polylineRenderer.lineWidth = 4
      return polylineRenderer
    }
    return nil
  }

  @IBAction func finishTracking(_ sender: Any) {
    timer?.invalidate()
    manager.stopUpdatingLocation()
    loadTrackerData()
    clearSaveTrackerdData()
    self.dismiss(animated: true, completion: nil)
  }

}
