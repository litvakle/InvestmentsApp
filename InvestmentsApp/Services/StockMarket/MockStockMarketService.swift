//
//  MockStockMarketService.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 15.06.2022.
//

import Foundation
import Combine

class MockStockMarketService: StockMarketService {
    let prices: [String: Double] = [
        "VOO": 350.12,
        "QQQ": 280.2,
        "IWL": 131.3,
        "GXC": 55.44,
        "MCHI": 60.11,
        "VGK": 101.19,
        "VEU": 99.82
    ]
    
    func getPrices(for tickets: [String]) -> AnyPublisher<[String : Double], NetworkManager.APIError> {
        return Just(tickets)
            .tryMap { [unowned self] tickets -> [String: Double] in
                var result = [String: Double]()
                for ticket in tickets {
                    if let price = self.prices[ticket] {
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
}
