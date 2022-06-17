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
                    .transition(.scale)
                    .zIndex(1)
            }
            
            if case .editOperation(let operation) = viewRouter.currentView {
                OperationView(vm: OperationViewModel(operation: operation))
                    .transition(.scale)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: viewRouter.currentView)
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
    static var stockData = StockData(stockMarketService: MockStockMarketService())
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(localStorage)
                .environmentObject(stockData)
                .environmentObject(ViewsRouter())
                .onAppear {
                    stockData.subscribeTo(localStorage: localStorage)
                }

            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(localStorage)
                .environmentObject(stockData)
                .environmentObject(ViewsRouter())
                .onAppear {
                    stockData.subscribeTo(localStorage: localStorage)
                }

        }
    }
}
