//
//  ViewsRouter.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 07.06.2022.
//

import Foundation

class ViewsRouter: ObservableObject {
    @Published private(set) var currentView: AppViews = .main
    
    enum AppViews: Hashable {
        case main
        case newOperation
        case editOperation(operation: MarketOperation)
    }
    
    func showNewOperationView() {
        currentView = .newOperation
    }
    
    func showEditOperationView(operation: MarketOperation) {
        currentView = .editOperation(operation: operation)
    }
    
    func showMainView() {
        currentView = .main
    }
}
