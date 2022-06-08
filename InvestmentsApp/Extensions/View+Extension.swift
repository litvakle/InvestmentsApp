//
//  View+Extension.swift
//  SimpleCalorie
//
//  Created by Lev Litvak on 20.05.2022.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
