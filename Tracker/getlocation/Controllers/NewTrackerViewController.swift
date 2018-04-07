//
//  NewTrackerViewController.swift
//  getlocation
//
//  Created by Олег Комаристый on 01.04.2018.
//  Copyright © 2018 Darthroid. All rights reserved.
//

import UIKit

class NewTrackerViewController: UITableViewController, UIPickerViewDelegate, UITextFieldDelegate {
  @IBOutlet weak var trackerIdTextField: UITextField!
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var startTrakingButton: UIBarButtonItem!
  @IBOutlet weak var updateFrequencyPicker: UIPickerView! {
    didSet {
      updateFrequencyPickerChanged()
    }
  }
  
  var updateFrequencyPickerHidden = true
  var updateFrequencyPickerOptions: [(time: String, value: Double)] = [("5 seconds", 5.0), ("10 seconds", 10.0), ("30 seconds", 30.0), ("1 minute", 60.0), ("5 minutes", 300.0), ("10 minutes", 600.0), ("30 minutes", 1800.0), ("1 hour", 3600.0)]
  var selectedUpdateFrequency: Double!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateFrequencyPicker.delegate = self
    trackerIdTextField.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func toggleUpdateFrequencyPicker() {
    updateFrequencyPickerHidden = !updateFrequencyPickerHidden
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  
  func updateFrequencyPickerChanged() {
    detailLabel.text = "\(updateFrequencyPicker.selectedRow(inComponent: 0))"
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    trackerIdTextField.resignFirstResponder()
    return true
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
    selectedUpdateFrequency = updateFrequencyPickerOptions[row].value
    detailLabel.text = updateFrequencyPickerOptions[row].time
  }
  
  func showError(message: String) {
    let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(ac, animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "start" {
      if let vc = segue.destination as? StartTrackingViewController {
        guard let id = trackerIdTextField.text, !id.isEmpty else {
          showError(message: "Please enter id")
          return
        }
        vc.id = id
        
        guard let updateFrequency = selectedUpdateFrequency, !selectedUpdateFrequency.isNaN else {
          showError(message: "Please select update frequency")
          return
        }
        vc.updateFrequency = updateFrequency
      }
    }
  }
  
  @IBAction func startTracking(_ sender: Any) {
    performSegue(withIdentifier: "start", sender: self)
  }
}
