//
//  NetworkManager.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 09.06.2022.
//

import Foundation
import Combine

class NetworkManager {
    enum APIError: Error, LocalizedError {
        case unknownError
        case apiError(_ description: String)
        case parserError(_ description: String)
        
        var errorDescription: String? {
            switch self {
            case .unknownError:
                return "Unknown API error"
            case .apiError(let description):
                return "API Error: \(description)"
            case .parserError(let description):
                return description
            }
        }
    }
    
    static func urlRequestPublisher(_ request: URLRequest) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknownError
                }
                
                if (httpResponse.statusCode == 401) {
                    throw APIError.apiError("Unauthorized");
                } else if (httpResponse.statusCode == 403) {
                    throw APIError.apiError("Resource forbidden");
                } else if (httpResponse.statusCode == 404) {
                    throw APIError.apiError("Resource not found");
                } else if (405..<500 ~= httpResponse.statusCode) {
                    throw APIError.apiError("client error");
                } else if (500..<600 ~= httpResponse.statusCode) {
                    throw APIError.apiError("server error");
                }
                
                return data
            }
            .eraseToAnyPublisher()
    }
    
    static func convertToAPIError(error: Error) -> APIError {
        if let error = error as? NetworkManager.APIError {
            return error
        } else {
            return NetworkManager.APIError.unknownError
        }
    }
}
