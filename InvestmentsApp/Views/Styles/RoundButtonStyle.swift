//
//  RoundButtonStyle.swift
//  InvestmentsApp
//
//  Created by Lev Litvak on 17.06.2022.
//

import Foundation
import SwiftUI

struct RoundButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.themeAccent)
            .font(.title3)
            .padding(12)
            .background(
                Circle()
                    .fill(Color.themeBackground)
                    .shadow(color: .themeAccent.opacity(0.3), radius: 10)
            )
            .padding(.horizontal)
    }
}
