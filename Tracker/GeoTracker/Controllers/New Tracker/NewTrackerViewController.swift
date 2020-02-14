//
//  NewTrackerViewController.swift
//  getlocation
//
//  Created by Олег Комаристый on 01.04.2018.
//  Copyright © 2018 Darthroid. All rights reserved.
//

import UIKit
import CoreLocation

class NewTrackerViewController: UITableViewController, Storyboarded {
    
    // MARK: - Outlets & connections
    
    @IBOutlet weak var trackerNameTextField: UITextField!
    @IBOutlet weak var detailLabel: UILabel!
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	@IBOutlet weak var startTrakingButton: UIBarButtonItem!
    @IBOutlet weak var updateFrequencyPicker: UIPickerView! {
        didSet {
            updateFrequencyPickerChanged()
        }
    }
            
	// MARK: - Public properties
	
	public var viewModel: TrackerRecorderViewModel!
	public weak var coordinator: NewTrackerCoordinator?
	
    // MARK: - ViewController LifeCycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateFrequencyPicker.delegate = self
        updateFrequencyPicker.dataSource = self
        trackerNameTextField.delegate = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.setupInterface()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.clearInputs()
		coordinator?.finish()
	}
    
    // MARK: - User defined methods
	
	private func setupInterface() {
		// selecting uipicker row programatically
		self.updateFrequencyPicker.selectRow(0, inComponent: 0, animated: true)
		self.updateFrequencyPicker.delegate?.pickerView?(self.updateFrequencyPicker,
														 didSelectRow: 0,
														 inComponent: 0)
	}
	
	private func clearInputs() {
		self.trackerNameTextField.endEditing(true)
		self.trackerNameTextField.text = ""
	}
    
    // MARK: - Actions methods
	@IBAction func cancel(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
    @IBAction func startTracking(_ sender: Any) {
		self.trackerNameTextField.endEditing(true)
		if viewModel.isValidTrackerInfo {
			coordinator?.startRecording(with: viewModel)
		} else {
			AlertManager.showError(title: ERROR_TITLE, message: "Please fill in all fields and try again")
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
		return viewModel.updateFrequencyOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return viewModel.updateFrequencyOptions[row].time
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		viewModel.trackerUpdateFrequency = viewModel.updateFrequencyOptions[row].value
		detailLabel.text = viewModel.updateFrequencyOptions[row].time
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
	func textFieldDidEndEditing(_ textField: UITextField) {
		viewModel.trackerName = trackerNameTextField.text?.trim() ?? ""
	}
	
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		trackerNameTextField.endEditing(true)
        return true
    }
}
