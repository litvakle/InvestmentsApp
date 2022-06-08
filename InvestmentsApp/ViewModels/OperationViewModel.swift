//
//  OperationViewModel.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Foundation
import Combine

class OperationViewModel: ObservableObject {
    @Published var type: MarketOperation.OperationType
    @Published var ticket: String
    @Published var date: Date
    @Published var quantity: Double
    @Published var price: Double
    @Published private(set) var sum: String = ""
    
    var id: String?
    var subsriptions = Set<AnyCancellable>()
    
    var title: String {
        return id == nil ? "New" : "Editing"
    }
    
    var canSave: Bool {
        return !ticket.isEmpty && quantity != 0 && price != 0
    }
    
    init(operation: MarketOperation? = nil) {
        ticket = operation?.ticket ?? ""
        date = operation?.date ?? Date()
        quantity = operation?.quantity ?? 0
        price = operation?.price ?? 0
        type = operation?.type ?? .buy
        id = operation?.id
        
        updateSum()
        
        setupSubsriptions()
    }
    
    private func setupSubsriptions() {
        $quantity
            .sink { [unowned self] _ in
                updateSum()
            }
            .store(in: &subsriptions)
        
        $price
            .sink { [unowned self] _ in
                updateSum()
            }
            .store(in: &subsriptions)
    }
    
    private func updateSum() {
        sum = String(format: "%.2f$", quantity * price)
    }
    
    func createOperation() -> MarketOperation {
        return MarketOperation(id: id ?? UUID().uuidString,
                               type: type, date: date, ticket: ticket, quantity: quantity, price: price)
    }
}
