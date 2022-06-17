//
//  OperationsViewModel.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Foundation
import Combine

class OperationsViewModel: ObservableObject {
    @Published private(set) var ticketOperations: [String: [MarketOperation]] = [:]
    
    private var subsriptions = Set<AnyCancellable>()
    private var localStorage: LocalStorage!
    
    var tickets: [String] {
        return Array(ticketOperations.keys).sorted()
    }
    
    func set(localStorage: LocalStorage) {
        self.localStorage = localStorage
        
        setupSubsriptions()
    }
    
    private func setupSubsriptions() {
        localStorage.$operations
            .sink { [unowned self] operations in
                updateTicketOperations(operations: operations)
            }
            .store(in: &subsriptions)
    }
    
    private func updateTicketOperations(operations: [MarketOperation]) {
        let ticketsInStorage = Set(operations.map { $0.ticket })
        let ticketsInCache = Set(ticketOperations.keys)
        let ticketsToDeleteFromCache = ticketsInCache.subtracting(ticketsInStorage)
        let ticketsToAddToCache = ticketsInStorage.subtracting(ticketsInCache)
        
        for ticket in ticketsToDeleteFromCache {
            ticketOperations[ticket] = nil
        }
        
        for ticket in ticketsToAddToCache {
            ticketOperations[ticket] = []
        }
    
        for ticket in tickets {
            let operationsInCache = Set(ticketOperations[ticket]!)
            let operationsInStorage = Set(operations.filter({ $0.ticket == ticket }))
            let operationsToDeleteFromCache = operationsInCache.subtracting(operationsInStorage)
            let operationsToAddToCache = operationsInStorage.subtracting(operationsInCache)

            for operation in operationsToDeleteFromCache {
                ticketOperations[ticket]!.removeAll(where: { $0.id == operation.id })
            }
            
            for operation in operationsToAddToCache {
                ticketOperations[ticket, default: []].append(operation)
            }
        }
    }
}
