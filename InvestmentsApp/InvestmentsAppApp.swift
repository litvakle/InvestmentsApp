//
//  InvestmentsAppApp.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 06.06.2022.
//

import SwiftUI

@main
struct InvestmentsAppApp: App {
    @StateObject var localStorage = LocalStorageViewModel(storageManager: CoreDataManager())
    @StateObject var viewRouter = ViewsRouter()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localStorage)
                .environmentObject(viewRouter)
        }
    }
}
