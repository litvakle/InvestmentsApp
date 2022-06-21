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
    @Published private(set) var sum: Double = 0
    @Published var textFieldIsValid: [OperationTextField: Bool] = [.ticket: false, .quantity: false, .price: false]
    @Published var activeTextField: OperationTextField?
    
    var id: String?
    var subsriptions = Set<AnyCancellable>()
    
    var title: String {
        return id == nil ? "New" : "Editing"
    }
    
    var canSave: Bool {
        return !ticket.isEmpty && quantity != 0 && price != 0
    }
    
    enum OperationTextField: Hashable {
        case ticket, quantity, price
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
        $ticket
            .sink { [unowned self] value in
                self.textFieldIsValid[.ticket] = (value.count >= 3)
            }
            .store(in: &subsriptions)
        
        $quantity
            .sink { [unowned self] value in
                self.textFieldIsValid[.quantity] = (value != 0)
                self.updateSum()
            }
            .store(in: &subsriptions)
        
        $price
            .sink { [unowned self] value in
                self.textFieldIsValid[.price] = (value != 0)
                self.updateSum()
            }
            .store(in: &subsriptions)
    }
    
    private func updateSum() {
        sum = quantity * price
    }
    
    func createOperation() -> MarketOperation {
        return MarketOperation(id: id ?? UUID().uuidString,
                               type: type, date: date, ticket: ticket, quantity: quantity, price: price)
    }
    
    func focusOnTheNextTextField() {
        switch activeTextField {
        case nil:
            activeTextField = .ticket
        case .ticket:
            activeTextField = .quantity
        case .quantity:
            activeTextField = .price
        case .price:
            activeTextField = nil
        }
    }
}
