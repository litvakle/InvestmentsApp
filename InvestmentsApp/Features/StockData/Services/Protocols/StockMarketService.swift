//
//  StockMarketService.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 13.06.2022.
//

import Foundation
import Combine

protocol StockMarketService {
    func getCurrentPrices(for tickets: [String]) -> AnyPublisher<[String: Double], NetworkManager.APIError>
    func getHistoricalPrices(for tickets: [String]) -> AnyPublisher<[HistoricalPrice], NetworkManager.APIError>
}
