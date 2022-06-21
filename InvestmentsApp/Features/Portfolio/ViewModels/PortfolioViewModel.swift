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
    @Published private(set) var profitChartData: [ChartData] = [] {
        didSet {
            print("profitChartData.count: \(profitChartData.count)")
        }
    }
    @Published private(set) var totalCost: Double = 0
    @Published private(set) var totalProfit: Double = 0
    @Published private(set) var totalProfitability: Double = 0
    @Published private(set) var portfolioIsUpdating = false
    @Published private(set) var chartIsUpdating = false
    
    private var localStorage: LocalStorage!
    private var stockData: StockData!
    
    private var subsriptions = Set<AnyCancellable>()
    
    func subscribeTo(localStorage: LocalStorage, stockData: StockData) {
        self.localStorage = localStorage
        self.stockData = stockData
        
        setupSubsriptions()
    }
    
    private func setupSubsriptions() {
        setupUpdatePortfolioSubscription()
        setupUpdateProfitChartDataSubscription()
    }
    
    private func setupUpdatePortfolioSubscription() {
        localStorage.$operations
            .receive(on: DispatchQueue.main)
            .combineLatest(stockData.$currentPrices)
            .filter({ !$0.0.isEmpty && !$0.1.isEmpty })
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { operations in
                print("Update portfolio (operations) - start")
                self.portfolioIsUpdating = true
            })
            .receive(on: DispatchQueue.global())
            .map(mapToPortfolio)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] portfolio in
                self.items = portfolio.items
                self.totalCost = portfolio.totalCost
                self.totalProfit = portfolio.totalProfit
                self.totalProfitability = portfolio.totalProfitability
                self.portfolioIsUpdating = false
                print("Update portfolio (operations) - end")
            }
            .store(in: &subsriptions)
    }
    
    private func setupUpdateProfitChartDataSubscription() {
        localStorage.$operations
            .receive(on: DispatchQueue.main)
            .combineLatest(stockData.$historicalPrices)
            .filter({ !$0.0.isEmpty && !$0.1.isEmpty })
            .handleEvents(receiveOutput: { _ in
                self.chartIsUpdating = true
            })
            .receive(on: DispatchQueue.global())
            .map(mapToProfitChartData)
            .filter({ !$0.isEmpty })
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] profitChartData in
                self.profitChartData = profitChartData
                self.chartIsUpdating = false
                print("Update chart data - end")
            }
            .store(in: &subsriptions)
    }
    
    private func mapToPortfolio(operations: [MarketOperation], currentPrices: [String: Double]) -> Portfolio {
        return Portfolio(operations: operations, currentPrices: currentPrices)
    }
}

// MARK: - Chart Data

extension PortfolioViewModel {
    private func mapToProfitChartData(operations: [MarketOperation], historicalPrices: [HistoricalPrice]) -> [ChartData] {
        var result = [ChartData]()

        let operations = operations.sorted(by: { $0.date < $1.date })
        var operationsByDay = [Date: [MarketOperation]]()
        for operation in operations {
            operationsByDay[operation.date.beginningOfTheDay(), default: []].append(operation)
        }
        
        var date = operations.first?.date.beginningOfTheDay() ?? Date().beginningOfTheDay()
        var ticketQuantity = [String: Double]()
        var expenses: Double = 0
        var income: Double = 0
        
        while date < Date().beginningOfTheDay() {
            if let currentOperations = operationsByDay[date] {
                for operation in currentOperations {
                    ticketQuantity[operation.ticket, default: 0] += operation.quantity * (operation.type == .buy ? 1 : -1)
                    expenses += operation.type == .buy ? operation.sum : 0
                    income += operation.type == .sell ? operation.sum : 0
                }
            }
            
            if let totalCostOnDate = totalCost(on: date, ticketQuantity: ticketQuantity, historicalPrices: historicalPrices) {
                let profit = totalCostOnDate + income - expenses
                result.append(ChartData(date: date, value: profit))
            }
            
            date = date.subtract(daysCount: -1)
        }

        return result
    }
    
    private func totalCost(on date: Date, ticketQuantity: [String: Double], historicalPrices: [HistoricalPrice]) -> Double? {
        var result: Double = 0
        
        for ticket in ticketQuantity.keys {
            if let currentPrice = historicalPrices.first(where: { $0.ticket == ticket && $0.date == date })?.priceClose {
                result += ticketQuantity[ticket]! * currentPrice
            } else {
                return nil
            }
        }
        
        return result
    }
}
