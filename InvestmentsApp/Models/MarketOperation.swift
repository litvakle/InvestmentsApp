//
//  MarketOperation.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 06.06.2022.
//
import Foundation

struct MarketOperation: Identifiable {
    var id: String = UUID().uuidString
    var type: OperationType
    var date: Date
    var ticket: String
    var quantity: Double
    var price: Double
    var sum: Double {
        return quantity * price
    }
    
    enum OperationType: String, Identifiable {
        case buy = "buy"
        case sell = "sell"
        
        var text: String {
            switch self {
            case .buy:
                return "Buy"
            case .sell:
                return "Sell"
            }
        }
        
        var id: Self { self }
    }
}

extension MarketOperation {
    static var mockData: [MarketOperation] {
        return [
            MarketOperation(type: .buy, date: Date.from(year: 2020, month: 11, day: 25), ticket: "VOO", quantity: 2.32, price: 255.51),
            MarketOperation(type: .buy, date: Date.from(year: 2020, month: 12, day: 24), ticket: "VOO", quantity: 1.55, price: 277.21),
            MarketOperation(type: .sell, date: Date.from(year: 2021, month: 1, day: 23), ticket: "VOO", quantity: 1, price: 299.02),
            MarketOperation(type: .buy, date: Date.from(year: 2020, month: 11, day: 25), ticket: "QQQ", quantity: 3.1, price: 300.01),
            MarketOperation(type: .buy, date: Date.from(year: 2020, month: 12, day: 22), ticket: "QQQ", quantity: 1, price: 320),
            MarketOperation(type: .buy, date: Date.from(year: 2022, month: 6, day: 2), ticket: "QQQ", quantity: 1, price: 400.15)
        ]
    }
}
