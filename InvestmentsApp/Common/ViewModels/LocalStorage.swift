//
//  LocalStorage.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 08.06.2022.
//

import Foundation
import Combine

class LocalStorage: ObservableObject {
    @Published var operations: [MarketOperation] = []

    var storageManager: LocalStorageManager
    
    init(storageManager: LocalStorageManager) {
        self.storageManager = storageManager
        
        self.loadOperations()
    }
    
    func loadOperations() {
        operations = storageManager.getOperations()
    }
    
    func save(operation: MarketOperation) {
        storageManager.save(operation: operation)
        
        if let index = self.operations.firstIndex(where: { $0.id == operation.id }) {
            self.operations[index] = operation
        } else {
            self.operations.append(operation)
        }
    }
    
    func delete(operation: MarketOperation) {
        self.storageManager.delete(operation: operation)
        self.operations.removeAll(where: { $0.id == operation.id })
    }
}
