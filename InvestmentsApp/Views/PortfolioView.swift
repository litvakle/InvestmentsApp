//
//  PortfolioView.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 06.06.2022.
//

import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject var localStorage: LocalStorageViewModel
    @StateObject var vm = PortfolioViewModel()
    
    var body: some View {
        VStack {
            toolbar
            
            List {
                summary
                
                details
            }
            .listStyle(.plain)
        }
        .onAppear {
            vm.set(localStorage: localStorage)
        }
    }
    
    var toolbar: some View {
        Text("Portfolio")
            .font(.largeTitle)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
    
    var summary: some View {
        Section {
            HStack {
                Text("Total cost")
                Spacer()
                Text(String(format: "%.2f$", vm.totalCost))
            }
            
            HStack {
                Text("Total profit")
                Spacer()
                Text(String(format: "%.2f$", vm.totalProfit))
                    .foregroundColor(vm.totalProfit >= 0 ? .green : .red)
            }
            
            HStack {
                Text("Total profitability")
                Spacer()
                Text(String(format: "%.2f\("%")%", vm.totalProfitability))
                    .foregroundColor(vm.totalProfitability >= 0 ? .green : .red)
            }
        } header: {
            Text("Summary")
        }
        .font(.headline)
    }
    
    var details: some View {
        Section {
            ForEach(vm.items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.ticket)
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text(String(format: "Quantity: %.2f", item.quantity))
                                Text(String(format: "Price: %.2f$", item.price))
                            }
                            
                            HStack {
                                Text(String(format: "Expenses: %.2f$", item.expenses))
                                Text(String(format: "Income: %.2f$", item.income))
                            }
                        }
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(String(format: "%.2f$", item.currentCost))
                        Text(String(format: "%.2f$", item.profit))
                            .foregroundColor(item.profit >= 0 ? .green: .red)
                        Text(String(format: "%.2f\("%")%", item.profitability))
                            .foregroundColor(item.profit >= 0 ? .green: .red)
                    }
                }
            }
        } header: {
            Text("Details")
                .font(.headline)
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
            .environmentObject(LocalStorageViewModel(storageManager: MockManager()))
    }
}
