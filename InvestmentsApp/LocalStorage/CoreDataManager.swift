//
//  CoreDataManager.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Foundation

class CoreDataManager: LocalStorageManager {
    func getOperations(from dateStart: Date, to dateEnd: Date) -> [MarketOperation] {
        return []
    }
    
    func getOperations() -> [MarketOperation] {
        return []
    }
    
    func save(operation: MarketOperation) {
        
    }
    
    func delete(operation: MarketOperation) {
        
    }
}
