//
//  RoboPearApp.swift
//  RoboPear
//
//  Created by Danylo Movchan on 10/12/24.
//

import SwiftUI

@main
struct YourAppName: App {
    @State private var showContentView = false
    
    var body: some Scene {
        WindowGroup {
            if showContentView {
                ContentView()
            } else {
                LandingView(showContentView: $showContentView)
            }
        }
    }
}
