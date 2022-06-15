//
//  AlphaVintageService.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Foundation
import Combine

struct PriceData: Codable {
    var price: String?
}

struct ErrorData: Codable {
    var code: Int
    var message: String
    var status: String
}

class AlphaVintageService: StockMarketService {
    func getPrices(for tickets: [String]) -> AnyPublisher<[String: Double], NetworkManager.APIError> {
        let request = pricesRequest(for: tickets)
        
        return NetworkManager.urlRequestPublisher(request)
            .tryMap { [unowned self] data -> [String: Double] in
                let result = self.decode(from: data)
                switch result {
                case .success(let prices):
                    return prices
                case .failure(let parseError):
                    throw parseError
                }
            }
            .mapError { error -> NetworkManager.APIError in
                if let error = error as? NetworkManager.APIError {
                    return error
                } else {
                    return NetworkManager.APIError.unknownError
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func pricesRequest(for tickets: [String]) -> URLRequest {
        let headers = [
            "X-RapidAPI-Key": "9eaee51d46msh714eb8ac253e883p1ea930jsn6a895191806a",
            "X-RapidAPI-Host": "twelve-data1.p.rapidapi.com"
        ]
        let tickets = tickets.joined(separator: ",")
        let urlString = "https://twelve-data1.p.rapidapi.com/price?symbol=\(tickets),&format=json&outputsize=30"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        return request
    }
    
    private func decode(from data: Data) -> Result<[String: Double], NetworkManager.APIError> {
        do {
            let pricesData = try JSONDecoder().decode([String: PriceData].self, from: data)
            var prices = [String: Double]()
            for item in pricesData {
                prices[item.key] = Double(item.value.price ?? "") ?? 0
            }

            return .success(prices)
        } catch(let error) {
            print(error.localizedDescription)
            if let errorData = try? JSONDecoder().decode(ErrorData.self, from: data) {
                return .failure(NetworkManager.APIError.parserError(errorData.message))
            }
            
            return .failure(NetworkManager.APIError.parserError(error.localizedDescription))
        }
    }
}

