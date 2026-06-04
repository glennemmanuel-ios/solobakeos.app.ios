//
//  View+Extensions.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/4/26.
//

import SwiftUI

extension View {
    func withKeyboardDoneButton() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
            }
        }
    }
}
