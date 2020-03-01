//
//  String.swift
//  getlocation
//
//  Created by Oleg Komaristy on 07.02.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation

extension String {
	public func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
