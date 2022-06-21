//
//  Portfolio.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 21.06.2022.
//

import Foundation

struct Portfolio {
    var items: [PortfolioItem] = []
    var totalCost: Double = 0
    var totalProfit: Double = 0
    var totalProfitability: Double = 0
    
    init(operations: [MarketOperation], currentPrices: [String: Double]) {
        updateItems(operations: operations, currentPrices: currentPrices)
        updateTotalParameters()
    }
    
    mutating func updateItems(operations: [MarketOperation], currentPrices: [String: Double]) {
        items = []
        
        var ticketOperations = [String: [MarketOperation]]()
        for operation in operations {
            ticketOperations[operation.ticket, default: []].append(operation)
        }
        
        for item in ticketOperations.sorted(by: { $0.key < $1.key }) {
            var portfolioItem = PortfolioItem()
            
            portfolioItem.ticket = item.key
            portfolioItem.price = currentPrices[item.key] ?? 0
            
            for operation in ticketOperations[item.key]! {
                portfolioItem.quantity += operation.type == .buy ? operation.quantity : -operation.quantity
                portfolioItem.expenses += operation.type == .buy ? operation.sum : 0
                portfolioItem.income += operation.type == .sell ? operation.sum : 0
            }
            
            portfolioItem.currentCost = portfolioItem.price * portfolioItem.quantity
            portfolioItem.profit = portfolioItem.currentCost + portfolioItem.income - portfolioItem.expenses
            portfolioItem.profitability = portfolioItem.profit / portfolioItem.expenses * 100
            
            items.append(portfolioItem)
        }
    }
    
    mutating func updateTotalParameters() {
        totalCost = 0
        totalProfit = 0
        var totalExpenses: Double = 0
        
        for item in items {
            totalCost += item.currentCost
            totalExpenses += item.expenses
            totalProfit += item.profit
        }
        
        totalProfitability = totalExpenses == 0 ? 0 : totalProfit / totalExpenses * 100
    }
}

struct PortfolioItem: Identifiable {
    var id = UUID().uuidString
    var ticket: String = ""
    var quantity: Double = 0
    var price: Double = 0
    var currentCost: Double = 0
    var expenses: Double = 0
    var income: Double = 0
    var profit: Double = 0
    var profitability: Double = 0
}
