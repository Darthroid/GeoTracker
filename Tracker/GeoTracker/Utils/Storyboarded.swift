//
//  Storyboarded.swift
//  getlocation
//
//  Created by Oleg Komaristy on 09.02.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import UIKit

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)

        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".")[1]

        // load our storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // instantiate a view controller with that identifier, and force cast as the type that was requested
		// swiftlint:disable force_cast
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
