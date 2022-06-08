//
//  LocalStorageViewModel.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 08.06.2022.
//

import Foundation
import Combine

class LocalStorageViewModel: ObservableObject {
    @Published var operations: [MarketOperation] = []
    
    var storageManager: LocalStorageManager
    
    init(storageManager: LocalStorageManager) {
        self.storageManager = storageManager
        
        loadOperations()
    }
    
    func loadOperations() {
        operations = storageManager.getOperations()
    }
    
    func save(operation: MarketOperation) {
        storageManager.save(operation: operation)
        
        if let index = operations.firstIndex(where: { $0.id == operation.id }) {
            operations[index] = operation
        } else {
            operations.append(operation)
        }
    }
    
    func delete(operation: MarketOperation) {
        storageManager.delete(operation: operation)
        
        operations.removeAll(where: { $0.id == operation.id })
    }
}
