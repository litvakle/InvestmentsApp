//
//  MockManager.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Foundation

class MockManager: LocalStorageManager {
    func getOperations(from dateStart: Date, to dateEnd: Date) -> [MarketOperation] {
        return MarketOperation.mockData
    }
    
    func getOperations() -> [MarketOperation] {
        return MarketOperation.mockData
    }
    
    func save(operation: MarketOperation) {
        
    }
    
    func delete(operation: MarketOperation) {
        
    }
}
