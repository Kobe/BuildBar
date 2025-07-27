//
//  ContentView.swift
//  BuildBar
//
//  Created by Ingo Stöcker on 7/26/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BuildBar")
                .font(.headline)
                .padding(.bottom, 4)
            
            Button("Check Build Status") {
                // TODO: Implement build status check
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(minWidth: 200)
    }
}

#Preview {
    ContentView()
}
