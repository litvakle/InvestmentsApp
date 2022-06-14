//
//  ContentView.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 06.06.2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var localStorage: LocalStorage
    @EnvironmentObject private var viewRouter: ViewsRouter
    @EnvironmentObject private var stockData: StockData
    
    @StateObject private var portfolioViewModel = PortfolioViewModel()
    
    var body: some View {
        ZStack {
            mainView
            
            if case .newOperation = viewRouter.currentView {
                OperationView(vm: OperationViewModel())
                    .zIndex(1)
            }
            
            if case .editOperation(let operation) = viewRouter.currentView {
                OperationView(vm: OperationViewModel(operation: operation))
                    .zIndex(1)
            }
        }
        .onAppear {
            portfolioViewModel.subscribeTo(localStorage: localStorage,
                                           stockData: stockData)
        }
    }
    
    var mainView: some View {
        TabView {
            PortfolioView(vm: portfolioViewModel)
                .tabItem {
                    VStack {
                        Image(systemName: "dollarsign.circle")
                        Text("Portfolio")
                    }
                }
                .refreshable {
                    stockData.updateAllPrices()
                }
            
            OperationsView()
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet.circle")
                        Text("Operations")
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var localStorage = LocalStorage(storageManager: MockManager())
    static var stockData = StockData(stockMarketService: AlphaVintageService())
    static var previews: some View {
        ContentView()
            .environmentObject(localStorage)
            .environmentObject(stockData)
            .environmentObject(ViewsRouter())
            .onAppear {
                stockData.subscribeTo(localStorage: localStorage)
            }
    }
}
