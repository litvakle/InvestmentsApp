//
//  MockStockMarketService.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 15.06.2022.
//

import Foundation
import Combine

class MockStockMarketService: StockMarketService {
    let currentPrices: [String: Double] = [
        "VOO": 350.12,
        "QQQ": 280.2,
        "IWL": 131.3,
        "GXC": 55.44,
        "MCHI": 60.11,
        "VGK": 101.19,
        "VEU": 99.82
    ]
    
    let historicalPrices: [HistoricalPrice] = [
        HistoricalPrice(ticket: "VOO", date: Date.from(year: 2020, month: 5, day: 10), priceClose: 200),
        HistoricalPrice(ticket: "VOO", date: Date.from(year: 2020, month: 5, day: 11), priceClose: 202),
        HistoricalPrice(ticket: "VOO", date: Date.from(year: 2020, month: 6, day: 10), priceClose: 200),
        HistoricalPrice(ticket: "VOO", date: Date.from(year: 2020, month: 6, day: 10), priceClose: 200),
        HistoricalPrice(ticket: "QQQ", date: Date.from(year: 2020, month: 5, day: 10), priceClose: 200),
        HistoricalPrice(ticket: "QQQ", date: Date.from(year: 2020, month: 5, day: 10), priceClose: 200),
        HistoricalPrice(ticket: "QQQ", date: Date.from(year: 2020, month: 6, day: 10), priceClose: 200),
        HistoricalPrice(ticket: "QQQ", date: Date.from(year: 2020, month: 5, day: 10), priceClose: 200),
    ]
    
    func getCurrentPrices(for tickets: [String]) -> AnyPublisher<[String : Double], NetworkManager.APIError> {
        return Just(tickets)
            .tryMap { [unowned self] tickets -> [String: Double] in
                var result = [String: Double]()
                for ticket in tickets {
                    if let price = self.currentPrices[ticket] {
                        result[ticket] = price
                    } else {
                        throw NetworkManager.APIError.unknownError
                    }
                }
                
                return result
            }
            .mapError({ _ in
                return NetworkManager.APIError.unknownError
            })
            .eraseToAnyPublisher()
    }
    
    func getHistoricalPrices(for tickets: [String]) -> AnyPublisher<[HistoricalPrice], NetworkManager.APIError> {
        return Just(tickets)
            .tryMap { [unowned self] tickets -> [HistoricalPrice] in
                var result = [HistoricalPrice]()
                for ticket in tickets {
                    let ticketPrices = self.historicalPrices.filter({ $0.ticket == ticket })
                    if ticketPrices.isEmpty {
                        throw NetworkManager.APIError.unknownError
                    }
                    
                    result += ticketPrices
                }
                
                return result
            }
            .mapError({ _ in
                return NetworkManager.APIError.unknownError
            })
            .eraseToAnyPublisher()
    }
}
