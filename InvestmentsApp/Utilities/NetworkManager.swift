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
        case unknownNetworkError
        case networkError(_ code: Int)
        case parserError(_ description: String)
        case unknownError(_ description: String)
        
        var errorDescription: String? {
            switch self {
            case .unknownNetworkError:
                return "Unknown network error"
            case .networkError(let code):
                return "Network error (code = \(code))"
            case .parserError(let description), .unknownError(let description):
                return description
            }
        }
    }
    
    static func handleRequest(_ request: URLRequest) -> AnyPublisher<Data, APIError> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else { throw APIError.unknownNetworkError }
                guard (200..<300).contains(httpResponse.statusCode) else {
                    throw APIError.networkError(httpResponse.statusCode)
                }
                
                return data
            }
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.unknownNetworkError
                }
            }
            .eraseToAnyPublisher()
    }
    
    static func handleCompletion(_ completion: Subscribers.Completion<Error>) -> Result<Bool, APIError> {
        switch completion {
        case .finished:
            return .success(true)
        case .failure(let error):
            if let error = error as? DecodingError {
                var errorToReport = error.localizedDescription
                switch error {
                case .dataCorrupted(let context):
                    let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                    errorToReport = "\(context.debugDescription) - (\(details))"
                case .keyNotFound(let key, let context):
                    let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                    errorToReport = "\(context.debugDescription) (key: \(key), \(details))"
                case .typeMismatch(let type, let context), .valueNotFound(let type, let context):
                    let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                    errorToReport = "\(context.debugDescription) (type: \(type), \(details))"
                @unknown default:
                    break
                }
                
                return .failure(APIError.parserError(errorToReport))
            } else if let error = error as? APIError {
                return .failure(error)
            } else {
                return .failure(APIError.unknownError(error.localizedDescription))
            }
        }
    }
}
