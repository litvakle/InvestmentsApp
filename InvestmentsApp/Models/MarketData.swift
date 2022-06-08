//
//  MarketData.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 06.06.2022.
//

import Foundation

struct MarketData {
    var id: String = UUID().uuidString
    var date: Date
    var ticket: String
    var price: Double
}
