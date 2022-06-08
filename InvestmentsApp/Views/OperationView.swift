//
//  OperationView.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import SwiftUI

struct OperationView: View {
    @EnvironmentObject private var localStorage: LocalStorageViewModel
    @EnvironmentObject private var viewRouter: ViewsRouter
    @ObservedObject var vm: OperationViewModel
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                toolbar
                
                List {
                    inputFields
                        
                    HStack {
                        Text("Total sum")
                        Text(vm.sum)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(vm.type == .buy ? .green : .red)
                    }
                    .font(.headline)
                }
                .padding()
                .listStyle(.plain)
                
                Spacer()
            }
        }
        
    }
    
    var toolbar: some View {
        HStack {
            Button {
                viewRouter.showMainView()
            } label: {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.largeTitle)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Text(vm.title)
                .font(.headline)
            
            Spacer()
            
            Button {
                localStorage.save(operation: vm.createOperation())
                viewRouter.showMainView()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.largeTitle)
                    .padding(.horizontal)
            }
            .disabled(!vm.canSave)
        }
    }
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        return formatter
    }
    
    var inputFields: some View {
        Group {
            Picker("Title", selection: $vm.type) {
                Text("Buy")
                    .tag(MarketOperation.OperationType.buy)
                
                Text("Sell")
                    .tag(MarketOperation.OperationType.sell)
            }
            .pickerStyle(.segmented)
            
            DatePicker("Date", selection: $vm.date, in: ...Date(), displayedComponents: .date)
            
            HStack {
                Text("Ticket")
                
                TextField("...", text: $vm.ticket)
                    .keyboardType(.alphabet)
                    .textInputAutocapitalization(.characters)
                    .disableAutocorrection(true)
                    .multilineTextAlignment(.trailing)
            }
            
            HStack {
                Text("Quantity")
                TextField("Enter quantity...", value: $vm.quantity, formatter: formatter)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(vm.type == .buy ? .green : .red)
            }
            
            HStack {
                Text("Price")
                
                TextField("Enter Price...", value: $vm.price, formatter: formatter)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(vm.type == .buy ? .green : .red)
            }
        }
    }
}

struct OperationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OperationView(vm: OperationViewModel(operation: MarketOperation.mockData[0]))
                .environmentObject(LocalStorageViewModel(storageManager: MockManager()))
            
            OperationView(vm: OperationViewModel())
                .environmentObject(LocalStorageViewModel(storageManager: MockManager()))
        }
    }
}
