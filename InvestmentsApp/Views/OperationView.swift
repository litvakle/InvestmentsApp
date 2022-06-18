//
//  OperationView.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import SwiftUI

struct OperationView: View {
    @EnvironmentObject private var localStorage: LocalStorage
    @EnvironmentObject private var viewRouter: ViewsRouter
    @ObservedObject var vm: OperationViewModel
    
    @FocusState private var activeTextField: OperationViewModel.OperationTextField?

    @State private var backButtonRotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                toolbar
                
                List {
                    inputFields
                        .listRowSeparator(.hidden)
                    
                    totalSum
                        .listRowSeparator(.hidden)
                }
                .listStyle(.inset)
                
                Spacer()
                
                if vm.activeTextField != nil && vm.textFieldIsValid[vm.activeTextField!]! {
                    Button {
                        vm.focusOnTheNextTextField()
                    } label: {
                        Text("Done")
                            .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .transition(.move(edge: .trailing))
                }
            }
            .animation(.easeInOut, value: vm.textFieldIsValid)
            .onChange(of: activeTextField) { newValue in
                vm.activeTextField = newValue
            }
            .onChange(of: vm.activeTextField) { newValue in
                    activeTextField = newValue
            }
        }
    }
    
    var toolbar: some View {
        HStack {
            Button {
                backButtonRotation = 180
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    viewRouter.showMainView()
                }
            } label: {
                Image(systemName: "chevron.backward")
                    .rotationEffect(Angle(degrees: backButtonRotation))
                    .animation(.easeInOut(duration: 0.5), value: backButtonRotation)
            }
            .buttonStyle(RoundButtonStyle())
            
            Spacer()
            
            Text(vm.title)
                .font(.headline)
            
            Spacer()
            
            Button {
                localStorage.save(operation: vm.createOperation())
                viewRouter.showMainView()
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(RoundButtonStyle())
            .disabled(!vm.canSave)
        }
        .modifier(ToolBarModifier())
    }
    
    var totalSum: some View {
        HStack {
            Text("Total sum")
            Text(vm.sum.toCurrencyString())
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.headline)
    }
}

extension OperationView {
    var inputFields: some View {
        Group {
            operationType
            
            DatePicker("Date", selection: $vm.date, in: ...Date(), displayedComponents: .date)
            
            ticket
                
            quantity
            
            price
        }
    }
    
    var operationType: some View {
        Picker("Title", selection: $vm.type) {
            Text("Buy")
                .tag(MarketOperation.OperationType.buy)
            
            Text("Sell")
                .tag(MarketOperation.OperationType.sell)
        }
        .pickerStyle(.segmented)
    }
    
    var ticket: some View {
        TextField("XXX", text: $vm.ticket)
            .focused($activeTextField, equals: .ticket)
            .keyboardType(.alphabet)
            .textInputAutocapitalization(.characters)
            .disableAutocorrection(true)
            .textFieldStyle(OperationTextFieldStyle(
                title: "Ticket", currentTextField: .ticket, vm: vm))
    }
    
    var quantity: some View {
        TextField("0.000", value: $vm.quantity, formatter: formatter(fractionDigits: 4))
            .focused($activeTextField, equals: .quantity)
            .keyboardType(.decimalPad)
            .textFieldStyle(
                OperationTextFieldStyle(
                    title: "Quantity", currentTextField: .quantity, vm: vm))
    }
    
    var price: some View {
        TextField("0.00", value: $vm.price, formatter: formatter(fractionDigits: 8))
            .focused($activeTextField, equals: .price)
            .keyboardType(.decimalPad)
            .textFieldStyle(
                OperationTextFieldStyle(
                    title: "Price ($)", currentTextField: .price, vm: vm))
    }
    
    func formatter(fractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = ""
        formatter.maximumFractionDigits = fractionDigits
        formatter.locale = .current
        
        return formatter
    }
}

struct OperationTextFieldStyle: TextFieldStyle {
    var title: String
    var currentTextField: OperationViewModel.OperationTextField
    var vm: OperationViewModel
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Text(title)

            configuration
                .multilineTextAlignment(.trailing)

            if vm.textFieldIsValid[currentTextField] ?? false {
                Button {
                    vm.focusOnTheNextTextField()
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
                .transition(.scale(scale: 0.1, anchor: .trailing))
                .buttonStyle(.plain)
                .disabled(vm.activeTextField != currentTextField)
            }
        }
        .animation(.easeInOut, value: vm.textFieldIsValid[currentTextField])
    }
}

struct OperationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OperationView(vm: OperationViewModel(operation: MarketOperation.mockData[0]))
                .environmentObject(LocalStorage(storageManager: MockManager()))
            
            OperationView(vm: OperationViewModel(operation: MarketOperation.mockData[0]))
                .environmentObject(LocalStorage(storageManager: MockManager()))
                .preferredColorScheme(.dark)
            
            OperationView(vm: OperationViewModel())
                .environmentObject(LocalStorage(storageManager: MockManager()))
        }
    }
}
