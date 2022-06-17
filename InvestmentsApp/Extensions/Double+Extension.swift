//
//  Double+Extension.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 17.06.2022.
//

import Foundation

extension Double {
    func toCurrencyString() -> String {
        return currencyFormatter(maxFractionDigits: 2).string(for: self) ?? "$0.00"
    }
    
    func toCurrencyStringLong() -> String {
        return currencyFormatter(maxFractionDigits: 6).string(for: self) ?? "$0.000000"
    }
    
    private func currencyFormatter(maxFractionDigits: Int) -> Formatter {
        let formatter = NumberFormatter()
        
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = maxFractionDigits
        
        return formatter
    }
    
    func toPercentString() -> String {
        return toNumberString() + "%"
    }
    
    func toNumberString() -> String {
        return String(format: "%.2f", self)
    }
}
