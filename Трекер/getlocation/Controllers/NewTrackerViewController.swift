//
//  NewTrackerViewController.swift
//  getlocation
//
//  Created by Олег Комаристый on 01.04.2018.
//  Copyright © 2018 Darthroid. All rights reserved.
//

import UIKit

class NewTrackerViewController: UITableViewController, UIPickerViewDelegate {
  @IBOutlet weak var trackerIdTextField: UITextField!
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var updateFrequencyPicker: UIPickerView!
  @IBOutlet weak var startTrakingButton: UIBarButtonItem!
  
  var updateFrequencyPickerHidden = true
  var updateFrequencyPickerOptions: [(time: String, value: Double)] = [("5 seconds", 5.0), ("10 seconds", 10.0), ("30 seconds", 30.0), ("1 minute", 60.0), ("5 minutes", 300.0), ("10 minutes", 600.0), ("30 minutes", 1800.0), ("1 hour", 3600.0)]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateFrequencyPicker.delegate = self
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  func updateFrequencyPickerChanged() {
    detailLabel.text = "\(updateFrequencyPicker.selectedRow(inComponent: 0))"
  }
  
  func toggleUpdateFrequencyPicker() {
    updateFrequencyPickerHidden = !updateFrequencyPickerHidden
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 1 && indexPath.row == 0 {
      toggleUpdateFrequencyPicker()
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if updateFrequencyPickerHidden && indexPath.section == 1 && indexPath.row == 1 {
      return 0
    } else {
      return super.tableView(tableView, heightForRowAt: indexPath)
    }
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return updateFrequencyPickerOptions.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return updateFrequencyPickerOptions[row].time
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    detailLabel.text = updateFrequencyPickerOptions[row].time
  }
  
  @IBAction func startTracking(_ sender: Any) {
    
  }
}
