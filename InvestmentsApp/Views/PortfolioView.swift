//
//  PortfolioView.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 06.06.2022.
//

import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject private var stockData: StockData
    @ObservedObject var vm: PortfolioViewModel
    
    var body: some View {
        VStack {
            toolBar
            
            List {
                Section {
                    summary
                }
                Section {
                    details
                }
            }
        }
        .alert("Attention", isPresented: $stockData.showAlert) {
            Button("OK") {}
        } message: {
            Text(stockData.errorMessage)
        }
    }
    
    var toolBar: some View {
        Text("Portfolio")
            .font(.headline)
            .fontWeight(.bold)
            .frame(height: 50)
    }
    
    var summary: some View {
        Group {
            if stockData.ticketsWithUpdatingPrices.isEmpty {
                VStack(alignment: .leading) {
                    Text(vm.totalCost.toCurrencyString())
                        .font(.system(size: 50, weight: .regular))
                    Text("\(vm.totalProfit.toCurrencyString()) (\(vm.totalProfitability.toPercentString()))")
                        .font(.system(size: 25, weight: .regular))
                        .foregroundColor(vm.totalProfit >= 0 ? .green : .red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.scale)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .animation(.easeInOut, value: stockData.ticketsWithUpdatingPrices)
    }
    
    var details: some View {
        VStack {
            ForEach(vm.items) { item in
                DetailsRowView(item: item)
                    .listRowBackground(Color.yellow)
                    .padding(.vertical, 5)
            }
        }
    }
}

struct DetailsRowView: View {
    @EnvironmentObject private var stockData: StockData
    var item: PortfolioViewModel.PortfolioItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(item.ticket)
                    .font(.headline)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Quantity: \(item.quantity.toNumberString())")
                    Text("Price: \(item.price.toCurrencyString())")
                }
                .foregroundColor(.secondary)
                .font(.subheadline)
            }
            
            Spacer()
            
            if stockData.ticketsWithUpdatingPrices.contains(item.ticket) {
                ProgressView()
            } else if item.price != 0 {
                VStack(alignment: .trailing) {
                    Text(item.currentCost.toCurrencyString())
                    Text(item.profit.toCurrencyString())
                        .foregroundColor(item.profit >= 0 ? .green: .red)
                    Text(item.profitability.toPercentString())
                        .foregroundColor(item.profit >= 0 ? .green: .red)
                }
            }
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var localStorage = LocalStorage(storageManager: MockManager())
    static var stockData = StockData(stockMarketService: MockStockMarketService())
    static var portfolioViewModel = PortfolioViewModel()
    
    static var previews: some View {
        Group {
            PortfolioView(vm: portfolioViewModel)
                .environmentObject(stockData)
                .onAppear {
                    stockData.subscribeTo(localStorage: localStorage)
                    portfolioViewModel.subscribeTo(localStorage: localStorage, stockData: stockData)
                }
            
            PortfolioView(vm: portfolioViewModel)
                .environmentObject(stockData)
                .preferredColorScheme(.dark)
                .onAppear {
                    stockData.subscribeTo(localStorage: localStorage)
                    portfolioViewModel.subscribeTo(localStorage: localStorage, stockData: stockData)
                }
        }
    }
}
