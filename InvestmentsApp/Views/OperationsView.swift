//
//  OperationsView.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import SwiftUI

struct OperationsView: View {
    @EnvironmentObject private var localStorage: LocalStorage
    @EnvironmentObject private var viewRouter: ViewsRouter
    @StateObject private var vm = OperationsViewModel()
    
    var body: some View {
        VStack(spacing: 2) {
            toolbar
            
            if vm.usingDateFilter {
                dateFilter
            }

            operationList
                .listStyle(.sidebar)
                .animation(.linear, value: vm.ticketOperations)
        }
        .animation(.easeInOut, value: vm.usingDateFilter)
        .onAppear {
            vm.set(localStorage: localStorage)
        }
    }
    
    var toolbar: some View {
        HStack {
            Button {
                vm.toggleDateFilter()
            } label: {
                Image(systemName: "calendar")
            }
            .buttonStyle(RoundButtonStyle())
            
            Text("Operations")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
            Button {
                viewRouter.showNewOperationView()
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(RoundButtonStyle())
        }
        .modifier(ToolBarModifier())
    }
    
    var dateFilter: some View {
        VStack {
            DatePicker("Date start", selection: $vm.dateStart,
                       in: ...Date(), displayedComponents: .date)
            DatePicker("Date end", selection: $vm.dateEnd,
                       in: ...Date(), displayedComponents: .date)
        }
        .padding()
        .padding(.horizontal)
    }
    
    var operationList: some View {
        List {
            ForEach(vm.tickets, id: \.self) { ticket in
                Section {
                    ForEach(vm.ticketOperations[ticket]!) { operation in
                        Button {
                            viewRouter.showEditOperationView(operation: operation)
                        } label: {
                            OperationRow(operation: operation)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        let operation = vm.ticketOperations[ticket]![indexSet.first!]
                        localStorage.delete(operation: operation)
                    }
                } header: {
                    Text(ticket)
                        .font(.headline)
                        .padding(.top, vm.tickets.first == ticket ? 10 : 0)
                }
            }
        }
        .background(Color.clear)
    }
}

struct OperationRow: View {
    var operation: MarketOperation
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(operation.type.text)
                        .foregroundColor(operation.type == .buy ? .green : .red)
                    Text(operation.date.toString())
                    Spacer()
                    Text(String(format: "%.2f$", operation.sum))
                }
                
                HStack(spacing: 15) {
                    Text(String(format: "Quantity: %.2f", operation.quantity))
                    Text(String(format: "Price: %.2f$", operation.price))
                }
                .foregroundColor(.secondary)
                .font(.subheadline)
            }
            
            Image(systemName: "chevron.forward")
                .foregroundColor(.secondary)
        }
    }
}

struct OperationsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OperationsView()
                .environmentObject(LocalStorage(storageManager: MockManager()))
                .environmentObject(ViewsRouter())
            
            OperationsView()
                .environmentObject(LocalStorage(storageManager: MockManager()))
                .environmentObject(ViewsRouter())
                .preferredColorScheme(.dark)
        }
    }
}
