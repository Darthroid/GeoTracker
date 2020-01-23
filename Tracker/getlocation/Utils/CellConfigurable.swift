//
//  CellConfigurable.swift
//  getlocation
//
//  Created by Oleg Komaristy on 21.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation

protocol CellConfigurable {
    func setup(viewModel: RowViewModel)
}

protocol RowViewModel {}
