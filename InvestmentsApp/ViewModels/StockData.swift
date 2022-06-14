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
        localStorage.$operations
            .map { [unowned self] operations in
                return operations
                    .map { $0.ticket }
                    .filter { self.prices[$0] == nil }
            }
            .filter({ !$0.isEmpty })
            .flatMap({ [unowned self] tickets in
                return self.stockMarketService.getPrices(for: tickets)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                let result = NetworkManager.handleCompletion(completion)
                switch result {
                case .success(_):
                    break
                case .failure(let apiError):
                    print(apiError.localizedDescription)
                }
            }, receiveValue: { [unowned self] receivedPrices in
                for item in receivedPrices {
                    self.prices[item.key] = item.value
                }
            })
            .store(in: &subsriptions)
    }
}

