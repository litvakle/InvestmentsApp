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
    @Published var dateStart = Date()
    @Published var dateEnd = Date()
    @Published private(set) var usingDateFilter = false
    
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
            .combineLatest($usingDateFilter, $dateStart, $dateEnd)
            .receive(on: DispatchQueue.global())
            .map(mapToTicketOperations)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] ticketOperations in
                self.ticketOperations = ticketOperations
            }
            .store(in: &subsriptions)
    }
    
    private func mapToTicketOperations(operations: [MarketOperation], usingFilter: Bool,
                                       dateStart: Date, dateEnd: Date) -> [String: [MarketOperation]] {
        var result = [String: [MarketOperation]]()
        
        let dateStart = dateStart.beginningOfTheDay()
        let dateEnd = dateEnd.endOfTheDay()
        let operations = operations.filter({ !usingFilter || (dateStart <= $0.date && $0.date <= dateEnd) })

        for operation in operations {
            result[operation.ticket, default: []].append(operation)
        }
                      
        return result
    }
    
    func toggleDateFilter() {
        usingDateFilter.toggle()
    }
}
