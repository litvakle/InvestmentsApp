//
//  AlphaVintageService.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Foundation
import Combine

class AlphaVintageService: StockMarketService {
    func getPrices(for tickets: [String]) -> AnyPublisher<[String: Double], Error> {
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
        
        return NetworkManager.handleRequest(request)
            .decode(type: [String: PriceData].self, decoder: JSONDecoder())
            .map { (data: [String: PriceData]) -> [String: Double] in
                var convertedPrices = [String: Double]()
                for item in data {
                    convertedPrices[item.key] = Double(item.value.price) ?? 0
                }
                
                return convertedPrices
            }
            .eraseToAnyPublisher()
    }
}

struct PriceData: Codable {
  var price: String
}
