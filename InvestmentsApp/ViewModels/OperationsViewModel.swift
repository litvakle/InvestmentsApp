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
        return Array(ticketOperations.keys)
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
        ticketOperations.removeAll()
        
        for operation in operations {
            ticketOperations[operation.ticket, default: []].append(operation)
        }
    }
}
