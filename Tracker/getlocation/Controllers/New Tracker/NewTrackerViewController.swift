//
//  NewTrackerViewController.swift
//  getlocation
//
//  Created by Олег Комаристый on 01.04.2018.
//  Copyright © 2018 Darthroid. All rights reserved.
//

import UIKit
import CoreLocation

class NewTrackerViewController: UITableViewController {
    
    // MARK: - Outlets & connections
    
    @IBOutlet weak var trackerNameTextField: UITextField!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var startTrakingButton: UIBarButtonItem!
    @IBOutlet weak var updateFrequencyPicker: UIPickerView! {
        didSet {
            updateFrequencyPickerChanged()
        }
    }
    
    // MARK: - Private properties
    
    private var updateFrequencyPickerOptions = UPDATE_FREQUENCY_OPTIONS
    private var selectedUpdateFrequency: Double?
    
    // MARK: - ViewController LifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateFrequencyPicker.delegate = self
        updateFrequencyPicker.dataSource = self
        trackerNameTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "start",
            let vc = segue.destination as? StartTrackingViewController,
            let trackerName = trackerNameTextField.text, !trackerName.isEmpty,
            let updateFrequency = selectedUpdateFrequency, !updateFrequency.isNaN
        {
            vc.trackerName = trackerName
            vc.updateFrequency = updateFrequency
        }
    }
    
    // MARK: - User defined methods
    
    private func validateTrackerAndStart() -> Bool {
        switch LocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            AlertManager.showError(title: ERROR_TITLE, message: "\(Bundle.main.displayName) has no access to location.")
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            guard   let trackerName = trackerNameTextField.text,
                    let updateFrequency = selectedUpdateFrequency,
                    !trackerName.isEmpty,
                    !updateFrequency.isNaN else
            {
                AlertManager.showError(title: ERROR_TITLE, message: "Please fill in all fields and try again")
                return false
            }
            
            return true
        @unknown default:
            return false
        }
    }
    
    // MARK: - Actions methods
    
    @IBAction func startTracking(_ sender: Any) {
        if validateTrackerAndStart() {
            performSegue(withIdentifier: "start", sender: self)
        }
    }
}

// MARK: - UITableViewDelegate methods

extension NewTrackerViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            showHideFrequencyPicker()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if updateFrequencyPicker.isHidden && indexPath.section == 1 && indexPath.row == 1 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}

// MARK: - UIPickerViewDelegate methods

extension NewTrackerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
    
    func showHideFrequencyPicker() {
        tableView.beginUpdates()
        updateFrequencyPicker.isHidden = !updateFrequencyPicker.isHidden
        tableView.endUpdates()
    }
    
    func updateFrequencyPickerChanged() {
        detailLabel.text = "\(updateFrequencyPicker.selectedRow(inComponent: 0))"
    }
}

// MARK: - UITextFieldDelegate methods

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        trackerNameTextField.resignFirstResponder()
        return true
    }
}
