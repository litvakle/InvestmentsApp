//
//  TwelveDataService.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Foundation
import Combine

class TwelveDataService: StockMarketService {
    let headers = [
        "X-RapidAPI-Key": "9eaee51d46msh714eb8ac253e883p1ea930jsn6a895191806a",
        "X-RapidAPI-Host": "twelve-data1.p.rapidapi.com"
    ]

    struct TDErrorData: Codable {
        var code: Int
        var message: String
        var status: String
    }
    
    private func decode<T: Decodable>(from data: Data, as type: T.Type) -> Result<T, NetworkManager.APIError> {
        do {
            let pricesData = try JSONDecoder().decode(T.self, from: data)
            return .success(pricesData)
        } catch(let error) {
            print(error.localizedDescription)
            if let errorData = try? JSONDecoder().decode(TDErrorData.self, from: data) {
                return .failure(NetworkManager.APIError.parserError(errorData.message))
            }
            
            return .failure(NetworkManager.APIError.parserError(error.localizedDescription))
        }
    }
}

// MARK: - Current Prices

extension TwelveDataService {
    struct TDCurrentPriceData: Codable {
        var price: String?
    }
    
    func getCurrentPrices(for tickets: [String]) -> AnyPublisher<[String: Double], NetworkManager.APIError> {
        let request = currentPricesRequest(for: tickets)
        
        return NetworkManager.urlRequestPublisher(request)
            .tryMap { [unowned self] data -> [String: Double] in
                let result = self.decode(from: data, as: [String: TDCurrentPriceData].self)
                switch result {
                case .success(let currentPricesData):
                    return convertToTheDesiredFormat(currentPricesData: currentPricesData)
                case .failure(let parseError):
                    throw parseError
                }
            }
            .mapError { NetworkManager.convertToAPIError(error: $0) }
            .eraseToAnyPublisher()
    }
    
    private func currentPricesRequest(for tickets: [String]) -> URLRequest {
        let tickets = tickets.joined(separator: ",")
        let urlString = "https://twelve-data1.p.rapidapi.com/price?symbol=\(tickets),&format=json&outputsize=30"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        return request
    }
    
    private func convertToTheDesiredFormat(currentPricesData: [String: TDCurrentPriceData]) -> [String: Double] {
        var prices = [String: Double]()
        
        for item in currentPricesData {
            prices[item.key] = Double(item.value.price ?? "") ?? 0
        }
        
        return prices
    }
}

// MARK: - Time Series Prices

extension TwelveDataService {
    struct TDHistoricalPrices: Codable {
        var values: [TDHistoricalPriceData]
    }
    
    struct TDHistoricalPriceData: Codable {
        var date: String
        var close: String
        
        enum CodingKeys: String, CodingKey {
            case date = "datetime"
            case close
        }
    }
    
    func getHistoricalPrices(for tickets: [String]) -> AnyPublisher<[HistoricalPrice], NetworkManager.APIError> {
        let request = historicalPricesRequest(for: tickets)
        
        return NetworkManager.urlRequestPublisher(request)
            .tryMap { [unowned self] data -> [HistoricalPrice] in
                let result = self.decode(from: data, as: [String: TDHistoricalPrices].self)
                switch result {
                case .success(let historicalPricesData):
                    return convertToTheDesiredFormat(historicalPricesData: historicalPricesData)
                case .failure(let parseError):
                    throw parseError
                }
            }
            .mapError { NetworkManager.convertToAPIError(error: $0) }
            .eraseToAnyPublisher()
    }
    
    private func historicalPricesRequest(for tickets: [String]) -> URLRequest {
        let tickets = tickets.joined(separator: "%2C")
        let urlString = "https://twelve-data1.p.rapidapi.com/time_series?symbol=\(tickets)%2C&interval=1day&outputsize=5000&format=json"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        return request
    }
    
    func convertToTheDesiredFormat(historicalPricesData: [String: TDHistoricalPrices]) -> [HistoricalPrice] {
        var result = [HistoricalPrice]()
        
        for item in historicalPricesData {
            let historicalPrices = item.value.values.map({ HistoricalPrice(
                ticket: item.key,
                date: Date.from(dateString: $0.date, dateFormat: "yyyy-MM-dd") ,
                priceClose: Double($0.close) ?? 0) })
            
            result += historicalPrices
        }

        return result
    }
}

