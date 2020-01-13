//
//  AlertManager.swift
//  getlocation
//
//  Created by Oleg Komaristy on 09.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import Foundation
import UIKit

class AlertManager {
    public static func showError(title: String,
                                 message: String,
                                 on viewController: UIViewController? = CommonUtils.visibleViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController?.present(alert, animated: true)
    }
}
