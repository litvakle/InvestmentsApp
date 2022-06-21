//
//  StockMarketService.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Combine
import Foundation

class StockData: ObservableObject {
    @Published private(set) var currentPrices: [String: Double] = [:]
    @Published private(set) var historicalPrices: [HistoricalPrice] = []
    @Published private(set) var ticketsWithUpdatingCurrentPrices = Set<String>()
    @Published private(set) var ticketsWithUpdatingHistoricalPrices = Set<String>() {
        didSet {
            print("ticketsWithUpdatingHistoricalPrices.count = \(ticketsWithUpdatingHistoricalPrices.count)")
        }
    }
    @Published var errorMessage: String = ""
    @Published var showAlert = false
    
    var isUpdatingHistoricalPrices: Bool {
        return !ticketsWithUpdatingHistoricalPrices.isEmpty
    }
    
    private var localStorage: LocalStorage!
    private var stockMarketService: StockMarketService
    private var subsriptions = Set<AnyCancellable>()
    
    init(stockMarketService: StockMarketService) {
        self.stockMarketService = stockMarketService
    }
    
    func subscribeTo(localStorage: LocalStorage) {
        self.localStorage = localStorage
        setupSubsriptions()
    }
    
    private func setupSubsriptions() {
        setupCurrentPricesSubscription()
        setupHistoricalPricesSubscription()
    }
    
    func updateAllCurrentPrices() {
        let publisher = Just(localStorage.operations)
            .map { Array(Set($0.map({ $0.ticket }))) }
            .eraseToAnyPublisher()
            
        handleCurrentPricesPublisher(publisher: publisher)
    }
    
    func updateAllHistoricalPrices() {
        let publisher = Just(localStorage.operations)
            .map { Array(Set($0.map({ $0.ticket }))) }
            .eraseToAnyPublisher()
            
        handleHistoricalPricesPublisher(publisher: publisher)
    }
    
    // MARK: - Current Prices
    
    private func setupCurrentPricesSubscription() {
        let publisher = localStorage.$operations
            .map { [unowned self] operations -> [String] in
                print("Update current prices - start")
                let ticketsWithoutPrices = Array(Set(operations.map { $0.ticket })).filter { self.currentPrices[$0] == nil }
                return ticketsWithoutPrices
            }
            .eraseToAnyPublisher()
        
        handleCurrentPricesPublisher(publisher: publisher)
    }
    
    private func handleCurrentPricesPublisher(publisher: AnyPublisher<[String], Never>) {
        publisher
            .filter({ !$0.isEmpty })
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [unowned self] tickets in
                self.ticketsWithUpdatingCurrentPrices = Set(tickets)
            })
            .flatMap { [unowned self] tickets in
                self.stockMarketService.getCurrentPrices(for: tickets)
                    .receive(on: DispatchQueue.main)
                    .catch { apiError -> Just<[String: Double]> in
                        print(apiError.localizedDescription)
                        self.errorMessage = "Error fetching prices: \(apiError.localizedDescription)"
                        self.showAlert = true
                        
                        return Just([:])
                    }
            }
            .sink { [unowned self] receivedPrices in
                for item in receivedPrices {
                    self.currentPrices[item.key] = item.value
                }
                
                print("Current prices: \(currentPrices)")
                self.ticketsWithUpdatingCurrentPrices.removeAll()
                print("Update current prices - end")
            }
            .store(in: &subsriptions)
    }
    
    // MARK: - Historical Prices
    
    private func setupHistoricalPricesSubscription() {
        let publisher = localStorage.$operations
            .receive(on: DispatchQueue.global())
            .map(mapToTicketsToUpdateHistoricalPrices)
            .eraseToAnyPublisher()
        
        handleHistoricalPricesPublisher(publisher: publisher)
    }
    
    private func mapToTicketsToUpdateHistoricalPrices(operations: [MarketOperation]) -> [String] {
        var historicalPricesMinMaxDate = [String: (min: Date, max: Date)]()
        
        for historicalPrice in historicalPrices {
            if let dates = historicalPricesMinMaxDate[historicalPrice.ticket] {
                let date = historicalPrice.date.beginningOfTheDay()
                let minDate = min(dates.min, date)
                let maxDate = max(dates.max, date)
                historicalPricesMinMaxDate[historicalPrice.ticket] = (minDate, maxDate)
            } else {
                let date = Date().beginningOfTheDay()
                historicalPricesMinMaxDate[historicalPrice.ticket] = (date, date)
            }
        }
        
        let minDate = operations.map({ $0.date }).min() ?? Date()
        let maxDate = Date().subtract(daysCount: 1).beginningOfTheDay()
        let allTickets = Set(operations.map({ $0.ticket }))
        let ticketsToUpdateHistoricalPrices = allTickets.filter {
            historicalPricesMinMaxDate[$0] == nil ||
            historicalPricesMinMaxDate[$0]!.min > minDate ||
            historicalPricesMinMaxDate[$0]!.max < maxDate }
        
        return Array(ticketsToUpdateHistoricalPrices)
    }
    
    private func handleHistoricalPricesPublisher(publisher: AnyPublisher<[String], Never>) {
        publisher
            .filter({ !$0.isEmpty })
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [unowned self] tickets in
                self.ticketsWithUpdatingHistoricalPrices = Set(tickets)
                print("ticketsWithUpdatingHistoricalPrices: \(ticketsWithUpdatingHistoricalPrices)")
            })
            .flatMap { [unowned self] tickets in
                self.stockMarketService.getHistoricalPrices(for: tickets)
                    .receive(on: DispatchQueue.main)
                    .catch { apiError -> Just<[HistoricalPrice]> in
                        print(apiError.localizedDescription)
                        self.errorMessage = "Error fetching prices: \(apiError.localizedDescription)"
                        self.showAlert = true
                        
                        return Just([])
                    }
            }
            .sink { [unowned self] receivedPrices in
                self.historicalPrices.removeAll(where: { ticketsWithUpdatingHistoricalPrices.contains($0.ticket) })
                self.historicalPrices += receivedPrices
                self.ticketsWithUpdatingHistoricalPrices.removeAll()
                print("Update historical prices - end")
            }
            .store(in: &subsriptions)
    }
}

