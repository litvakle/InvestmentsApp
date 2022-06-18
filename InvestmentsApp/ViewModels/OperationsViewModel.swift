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
            .sink { [unowned self] operations in
                updateTicketOperations(operations: operations, usingFilter: usingDateFilter,
                                       dateStart: dateStart, dateEnd: dateEnd)
            }
            .store(in: &subsriptions)
        
        $dateStart
            .sink { [unowned self] date in
                self.updateTicketOperations(operations: self.localStorage.operations, usingFilter: usingDateFilter,
                                            dateStart: date, dateEnd: dateEnd)
            }
            .store(in: &subsriptions)
        
        $dateEnd
            .sink { [unowned self] date in
                self.updateTicketOperations(operations: self.localStorage.operations, usingFilter: usingDateFilter,
                                            dateStart: dateStart, dateEnd: date)
            }
            .store(in: &subsriptions)
        
        $usingDateFilter
            .delay(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [unowned self] using in
                self.updateTicketOperations(operations: self.localStorage.operations, usingFilter: using,
                                            dateStart: dateStart, dateEnd: dateEnd)
            }
            .store(in: &subsriptions)
    }
    
    private func updateTicketOperations(operations: [MarketOperation], usingFilter: Bool, dateStart: Date, dateEnd: Date) {
        ticketOperations = [:]
        
        let dateStart = dateStart.beginningOfTheDay()
        let dateEnd = dateEnd.endOfTheDay()
        let operations = operations.filter({ !usingFilter || (dateStart <= $0.date && $0.date <= dateEnd) })

        for operation in operations {
            ticketOperations[operation.ticket, default: []].append(operation)
        }
    }
    
    func toggleDateFilter() {
        usingDateFilter.toggle()
    }
}
