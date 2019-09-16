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

class StartTrackingViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var statusTextView: UITextView!
    @IBOutlet weak var finishTrackingButton: UIButton!
    
    private let locationManager = CLLocationManager()
    var id: String?
    var updateFrequency: Double?
    weak var timer: Timer?
    var data: [NSManagedObject] = []
//    var location: [CLLocation] = []
//    let trackerData = TrackerPoint()
    var points = [TrackerPoint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        self.observeTrackerData()
    }
    
    // MARK: - Observing coordinates from CLLocationManager
    
    func observeTrackerData() {
//        switch CLLocationManager.authorizationStatus() {
//
//        case .notDetermined:
//            <#code#>
//        case .restricted:
//            <#code#>
//        case .denied:
//            <#code#>
//        case .authorizedAlways:
//            break
//        case .authorizedWhenInUse:
//            <#code#>
//        }
        timer = Timer.scheduledTimer(withTimeInterval: updateFrequency!, repeats: true) { (timer) in
            if  let latitude = self.locationManager.location?.coordinate.latitude,
                let longitude = self.locationManager.location?.coordinate.longitude,
                let id = self.id
            {
                let point = TrackerPoint(latitude: latitude,
                                         longitude: longitude,
                                         id: id,
                                         timestamp: Int64(NSDate().timeIntervalSince1970))
                self.points.append(point)
                print(point.latitude, point.longitude, point.id)
            }
            
//            self.trackerData.id = self.id
//            self.trackerData.latitude = self.manager.location?.coordinate.latitude
//            self.trackerData.longitude = self.manager.location?.coordinate.longitude
//            self.trackerData.timestamp = NSDate().timeIntervalSince1970
//            print(self.trackerData.latitude!, self.trackerData.longitude!, self.trackerData.timestamp!)
//            self.saveTrackerData()
        }
    }
    
    // MARK: - Saving observed data to CoreData
    
//    func saveTrackerData() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: "Data", in: managedContext)!
//        let dataToSave = NSManagedObject(entity: entity, insertInto: managedContext)
////
////        dataToSave.setValue(trackerData.latitude, forKeyPath: "latitude")
////        dataToSave.setValue(trackerData.longitude, forKey: "longitude")
////        dataToSave.setValue(trackerData.id, forKey: "id")
////        dataToSave.setValue(trackerData.timestamp, forKey: "timestamp")
//
//        do {
//            try managedContext.save()
//            data.append(dataToSave)
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }
    
    // MARK: - Loading data from CoreData
    
//    func loadTrackerData() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Data")
//
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                self.data = try managedContext.fetch(fetchRequest)
//                for alldata in self.data {
//                    usleep(1000000)
//                    self.sendTrackerData(lat: alldata.value(forKey: "latitude") as! Double,
//                                         lon: alldata.value(forKey: "longitude") as! Double,
//                                         id: alldata.value(forKey: "id") as! String,
//                                         timestamp: alldata.value(forKey: "timestamp") as! Double) { completion in
//                                            if completion {
//                                                print("Done")
//                                            }
//                    }
//                }
//            } catch let error as NSError {
//                print("Could not fetch. \(error), \(error.userInfo)")
//            }
//        }
//
//    }
    
    // MARK: - Sending all observed data to server
    
//    func sendTrackerData(lat: Double, lon: Double, id: String, timestamp: Double, completion:@escaping (_ result:Bool) -> Void) {
//        let url = "http://trackmygps.000webhostapp.com/index.php?action=insert&latitude=\(lat)&longitude=\(lon)&objectID=\(id)&date=\(String(timestamp))"
//        Alamofire.request(url).validate(statusCode: 200..<300).response { response in
//            if response.response?.statusCode == 200 {
//                completion(true)
//            }
//        }
//    }
    
    // MARK: - Clearing all data from CoreData
    
//    func clearSaveTrackerdData() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//        
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let delAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Data"))
//        
//        do {
//            try managedContext.execute(delAllReqVar)
//            print("Deleted")
//        }
//        catch {
//            print(error)
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
        LocationManager.shared.stopUpdatingLocation()
    }
    
    func saveTrackerData() {
        guard points.isEmpty == false else {
            AlertManager.showError(title: ERROR_TITLE, message: "No points to save")
            return
        }
        do {
            let _ = try CoreDataManager.shared.insertTracker(with: id ?? UUID().uuidString, points: points)

        } catch let error {
            AlertManager.showError(title: ERROR_TITLE, message: error.localizedDescription)
        }
    }
    
    @IBAction func finishTracking(_ sender: Any) {
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
        saveTrackerData()
        
        // TODO: waint until save operation is finished and then dismiss
        
//        loadTrackerData()
//        clearSaveTrackerdData()
        self.dismiss(animated: true, completion: nil)
    }
    
}

//TODO: Location update visualizing

extension StartTrackingViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        location.append(locations[0])
//        guard let points = self.points else { return }
        statusTextView.text = String(describing: manager.location)
        let spanX = 0.03
        let spanY = 0.03
        let newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: spanX, longitudeDelta: spanY))
        mapView.setRegion(newRegion, animated: true)
//
//        if points.count > 1 {
//            let sourceIndex = points.count - 1
//            let destinationIndex = location.count - 2
//
//            let c1 = location[sourceIndex].coordinate
//            let c2 = location[destinationIndex].coordinate
//            var a = [c1, c2]
//            let polyline = MKPolyline(coordinates: &a, count: a.count)
//            mapView.addOverlay(polyline)
//        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        assert(overlay is MKPolyline)
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.lineWidth = 4
        return polylineRenderer
    }
}
