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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    var refreshControl: UIRefreshControl!
    var data: [String: [ObjectData]]! = [:]
    let textCellIdentifier = "coordinatesCell"
    let regionRadius: CLLocationDistance = 1000
    var indexes = [String]()
    var dates = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        map.delegate = self
        
        refreshControl = UIRefreshControl() //pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh(sender: ViewController())
    }
    func throwError(message: String){   //alert, выбрасывающий ошибки при работе с программой
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func loadData()->Bool{  //загрузка данных с URL
        let urlPath: String = "http://trackmygps.000webhostapp.com/index.php?action=select" //url с запросом, по которому возвращаются данные из БД
        let url: NSURL = NSURL(string: urlPath)!
        do {
            let GpsData = try Data(contentsOf: url as URL)
            let json = try! JSONSerialization.jsonObject(with: GpsData, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSArray
            let item = json[0] as! Dictionary<String, AnyObject>
            let _date: AnyObject? = item["date"]
            let _id: AnyObject? = item["_id"]
            if _id as! String  == "0" && _date as! String == "0"
            {
                throwError(message: "БД пустая!")
                return false
            } else {
                    data.removeAll()
                    for index in 0...json.count-1{
                    let item = json[index] as! Dictionary<String,AnyObject>
                    if(data["\(item["objectID"] as! String)"] == nil)
                    {
                        data["\(item["objectID"] as! String)"] = []
                    }
                    data["\(item["objectID"] as! String)"]?.append(ObjectData(latitude: (item["latitude"] as AnyObject).doubleValue, longitude: (item["longitude"] as AnyObject).doubleValue, date: (item["date"] as? String)!))
                }
                indexes = [String](data.keys)
            }
        }
        catch {
            print("\(error)")
            throwError(message: "не удалось подключиться к серверу")
            return false
        }
        return true
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
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
        drawOnMap(object: "\(indexes[row])")
    }
    func refresh(sender:AnyObject) {    //pull-to-refresh для таблицы
        if loadData(){
            refreshControl.endRefreshing()
            tableView.reloadData()
        }else if !loadData(){
            refreshControl.endRefreshing()
            throwError(message: "Can't load any data!")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func centerMapOnLocation(location: CLLocation) {    //центрование карты на стартовой локации 
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: true)
    }
    func drawOnMap(object: String){ //отрисовка polyline-линии маршрута объекта на карте
        var i = 0
        dates = Array(repeating: String(), count: (data["\(object)"]?.count)!)
        var locations: [CLLocationCoordinate2D] = Array(repeating: CLLocationCoordinate2D(), count: (data["\(object)"]?.count)!)
        for keys in data{
            if keys.key == object{
                for values in keys.value{
                    locations[i] = CLLocationCoordinate2D(latitude: values.latitude, longitude: values.longitude)
                    dates[i] = values.date
                    i+=1
                }
            }
        }
        let polyLine = MKPolyline(coordinates: locations, count: locations.count)
        //polyLine.title = "\(String(describing: data["\(object)"]))"
        map.add(polyLine)
        
        UIView.animate(withDuration: 1.5, animations: { () -> Void in
            if let first = self.map.overlays.first {
                let rect = self.map.overlays.reduce(first.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)})
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
    @IBAction func changeMapStyle(_ sender: Any) {  //переключатель стилей карты (спутник, схема, гибрид)
        switch ((sender as AnyObject).selectedSegmentIndex) {
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
    @IBOutlet weak var map: MKMapView!
    @IBOutlet var tableView: UITableView!
}
