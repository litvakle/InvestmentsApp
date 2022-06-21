//
//  ChartData.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 21.06.2022.
//

import Foundation

struct ChartData: Identifiable {
    var id = UUID().uuidString
    var date: Date
    var value: Double
}
