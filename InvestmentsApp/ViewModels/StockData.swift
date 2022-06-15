//
//  StockMarketService.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Combine
import Foundation

class StockData: ObservableObject {
    @Published private(set) var prices: [String: Double] = [:]
    @Published private(set) var ticketsWithUpdatingPrices = Set<String>()
    @Published var errorMessage: String = ""
    @Published var showAlert = false
    
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
    
    func updateAllPrices() {
        let publisher = Just(localStorage.operations)
            .map { Array(Set($0.map({ $0.ticket }))) }
            .eraseToAnyPublisher()
            
        handleOperationsPublisher(publisher: publisher)
    }
    
    private func setupSubsriptions() {
        let publisher = localStorage.$operations
            .map { [unowned self] operations -> [String] in
                let ticketsWithoutPrices = Array(Set(operations.map { $0.ticket })).filter { self.prices[$0] == nil }
                return ticketsWithoutPrices
            }
            .eraseToAnyPublisher()
        
        handleOperationsPublisher(publisher: publisher)
    }
    
    private func handleOperationsPublisher(publisher: AnyPublisher<[String], Never>) {
        publisher
            .filter({ !$0.isEmpty })
            .handleEvents(receiveOutput: { [unowned self] tickets in
                self.ticketsWithUpdatingPrices = Set(tickets)
            })
            .flatMap { [unowned self] tickets in
                self.stockMarketService.getPrices(for: tickets)
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
                    self.prices[item.key] = item.value
                }
                
                print(prices)
                self.ticketsWithUpdatingPrices.removeAll()
            }
            .store(in: &subsriptions)
    }
}

