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
    
    @State private var refreshButtonRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 2) {
            toolBar
            
            ScrollView {
                summary
                    .padding()
                
                chartView
                    .padding()
                
                details
                .padding()
            }
        }
        .alert("Attention", isPresented: $stockData.showAlert) {
            Button("OK") {}
        } message: {
            Text(stockData.errorMessage)
        }
    }
    
    var toolBar: some View {
        HStack {
            Button {
//                vm.toggleDateFilter()
            } label: {
                Image(systemName: "info")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .buttonStyle(RoundButtonStyle())
            
            Text("Portfolio")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                Spacer()
    
                Button {
                    stockData.updateAllCurrentPrices()
                    stockData.updateAllHistoricalPrices()
                    refreshButtonRotation += 360
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .rotationEffect(Angle(degrees: refreshButtonRotation))
                .animation(.linear(duration: 1), value: refreshButtonRotation)
                .buttonStyle(RoundButtonStyle())
            }
        }
        .modifier(ToolBarModifier())
    }
    
    var summary: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(vm.totalCost.toCurrencyString())
                    .font(.system(size: 50, weight: .semibold))
                Text("\(vm.totalProfit.toCurrencyString()) (\(vm.totalProfitability.toPercentString()))")
                    .font(.system(size: 25, weight: .regular))
                    .foregroundColor(vm.totalProfit >= 0 ? .green : .red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(vm.portfolioIsUpdating ? 0 : 1)
        }
        .animation(.easeInOut, value: vm.portfolioIsUpdating)
    }
    
    var chartView: some View {
        VStack(alignment: .center) {
            if stockData.isUpdatingHistoricalPrices || vm.chartIsUpdating {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ChartView(chartData: vm.profitChartData)
                    .transition(.scale)
            }
        }
        .frame(height: 200)
        .animation(.easeInOut, value: stockData.isUpdatingHistoricalPrices)
        .animation(.easeInOut, value: vm.chartIsUpdating)
    }
    
    var details: some View {
        VStack {
            ForEach(vm.items) { item in
                DetailsRowView(item: item)
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
            
            if stockData.ticketsWithUpdatingCurrentPrices.contains(item.ticket) {
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
