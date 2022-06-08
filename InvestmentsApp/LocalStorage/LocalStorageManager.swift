//
//  LocalStorageManager.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Foundation

protocol LocalStorageManager {
    func getOperations(from dateStart: Date, to dateEnd: Date) -> [MarketOperation]
    func getOperations() -> [MarketOperation]
    func save(operation: MarketOperation)
    func delete(operation: MarketOperation)
}
