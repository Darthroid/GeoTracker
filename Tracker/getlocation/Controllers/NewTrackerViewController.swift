//
//  NewTrackerViewController.swift
//  getlocation
//
//  Created by Олег Комаристый on 01.04.2018.
//  Copyright © 2018 Darthroid. All rights reserved.
//

import UIKit

class NewTrackerViewController: UITableViewController {
    @IBOutlet weak var trackerIdTextField: UITextField!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var startTrakingButton: UIBarButtonItem!
    @IBOutlet weak var updateFrequencyPicker: UIPickerView! {
        didSet {
            updateFrequencyPickerChanged()
        }
    }
    
    private var updateFrequencyPickerOptions: [(time: String, value: Double)] = [("5 seconds", 5.0),
                                                                                 ("10 seconds", 10.0),
                                                                                 ("30 seconds", 30.0),
                                                                                 ("1 minute", 60.0),
                                                                                 ("5 minutes", 60.0 * 5),
                                                                                 ("10 minutes", 60.0 * 10),
                                                                                 ("30 minutes", 60.0 * 30),
                                                                                 ("1 hour", 60.0 * 60)]
    private var selectedUpdateFrequency: Double!
    
    // MARK: - ViewController LifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFrequencyPicker.delegate = self
        updateFrequencyPicker.dataSource = self
        trackerIdTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "start" {
            if let vc = segue.destination as? StartTrackingViewController {
                guard let id = trackerIdTextField.text, !id.isEmpty else {
                    AlertManager.showError(title: ERROR_TITLE, message: "Please enter id")
                    return
                }
                vc.id = id
                
                guard let updateFrequency = selectedUpdateFrequency, !selectedUpdateFrequency.isNaN else {
                    AlertManager.showError(title: ERROR_TITLE, message: "Please select update frequency")
                    return
                }
                vc.updateFrequency = updateFrequency
            }
        }
    }
    
    // MARK: - Actions methods
    
    @IBAction func startTracking(_ sender: Any) {
        switch LocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            AlertManager.showError(title: ERROR_TITLE, message: "\(Bundle.main.displayName) has no access to location.")
        case .authorizedAlways, .authorizedWhenInUse:
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
        trackerIdTextField.resignFirstResponder()
        return true
    }
}
