//
//  RoundButtonStyle.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 17.06.2022.
//

import Foundation
import SwiftUI

struct RoundButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isEnabled ? .themeAccent : .secondary)
            .font(.title3)
            .frame(width: 43, height: 43)
            .background(
                Circle()
                    .fill(isEnabled ? Color.themeBackground : .secondary.opacity(0.1))
                    .shadow(color: .themeAccent.opacity(0.3), radius: 10)
            )
            .padding(.horizontal)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}
