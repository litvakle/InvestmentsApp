//
//  PortfolioViewModel.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Foundation
import Combine

class PortfolioViewModel: ObservableObject {
    @Published private(set) var items: [PortfolioItem] = []
    @Published private(set) var totalCost: Double = 0
    @Published private(set) var totalProfit: Double = 0
    @Published private(set) var totalProfitability: Double = 0
    
    private var localStorage: LocalStorage!
    private var stockData: StockData!
    
    private var subsriptions = Set<AnyCancellable>()
    
    func subscribeTo(localStorage: LocalStorage, stockData: StockData) {
        self.localStorage = localStorage
        self.stockData = stockData
        
        setupSubsriptions()
    }
    
    private func setupSubsriptions() {
        localStorage.$operations
            .sink { [unowned self] _ in
                self.updatePortfolioItems()
                self.updateTotalParameters()
            }
            .store(in: &subsriptions)
        
        stockData.$prices
            .filter({ !$0.isEmpty })
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [unowned self] prices in
                self.updatePortfolioItems()
                self.updateTotalParameters()
            }
            .store(in: &subsriptions)
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
    
    private func updatePortfolioItems(logString: String = "") {
        print(logString)
        var ticketOperations = [String: [MarketOperation]]()

        for operation in localStorage.operations {
            ticketOperations[operation.ticket, default: []].append(operation)
        }
        
        items = []
        
        for item in ticketOperations.sorted(by: { $0.key < $1.key }) {
            var portfolioItem = PortfolioItem()
            
            portfolioItem.ticket = item.key
            portfolioItem.price = stockData.prices[item.key] ?? 0
            
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
    
    private func updateTotalParameters() {
        var totalCost: Double = 0
        var totalExpenses: Double = 0
        var totalProfit: Double = 0
        
        for item in items {
            totalCost += item.currentCost
            totalExpenses += item.expenses
            totalProfit += item.profit
        }
        
        self.totalCost = totalCost
        self.totalProfit = totalProfit
        totalProfitability = totalExpenses == 0 ? 0 : totalProfit / totalExpenses * 100
    }
}
