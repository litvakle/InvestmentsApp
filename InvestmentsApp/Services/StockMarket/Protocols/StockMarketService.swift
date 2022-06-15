//
//  StockMarketService.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 13.06.2022.
//

import Foundation
import Combine

protocol StockMarketService {
    func getPrices(for tickets: [String]) -> AnyPublisher<[String: Double], NetworkManager.APIError>
}
