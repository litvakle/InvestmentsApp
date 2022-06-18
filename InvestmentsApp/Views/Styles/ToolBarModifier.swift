//
//  ToolBarModifier.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 18.06.2022.
//

import Foundation
import SwiftUI

struct ToolBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.bottom)
            .frame(height: 50)
            .background(
                Color.themeBackground
                .edgesIgnoringSafeArea(.top)
                .shadow(color: .primary.opacity(0.2),
                        radius: 2))
    }
}
