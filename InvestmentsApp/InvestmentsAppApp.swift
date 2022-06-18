//
//  InvestmentsAppApp.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 06.06.2022.
//

import SwiftUI

@main
struct InvestmentsAppApp: App {
    @StateObject var localStorage = LocalStorage(storageManager: CoreDataManager())
    @StateObject var stockData = StockData(stockMarketService: AlphaVintageService())
    @StateObject var viewRouter = ViewsRouter()
    
    init() {
        UITableView.appearance().backgroundColor = .systemBackground
        UITableView.appearance().keyboardDismissMode = .onDrag
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localStorage)
                .environmentObject(viewRouter)
                .environmentObject(stockData)
                .onAppear {
                    stockData.subscribeTo(localStorage: localStorage)
                }
        }
    }
}
