//
//  ContentView.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 06.06.2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var localStorage: LocalStorageViewModel
    @EnvironmentObject var viewRouter: ViewsRouter
    
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
    }
    
    var mainView: some View {
        TabView {
            PortfolioView()
                .tabItem {
                    VStack {
                        Image(systemName: "dollarsign.circle")
                        Text("Portfolio")
                    }
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
    static var previews: some View {
        ContentView()
            .environmentObject(LocalStorageViewModel(storageManager: MockManager()))
            .environmentObject(ViewsRouter())
    }
}
