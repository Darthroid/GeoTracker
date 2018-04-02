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

class StartTrackingViewController: UIViewController {
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var statusTextView: UITextView!
  @IBOutlet weak var finishTrackingButton: UIButton!
  
  var id: String?
  var updateFrequency: Double?
  
  var trackerData: TrackerData?
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    trackerData?.id = id!
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
  @IBAction func finishTracking(_ sender: Any) {
  }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
