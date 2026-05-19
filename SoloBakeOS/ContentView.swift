//
//  ContentView.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/18/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        Text("Hello World!")
            .onAppear {
                PreviewData.sanityCheck()
            }
    }
}

#Preview {
    ContentView()
}
