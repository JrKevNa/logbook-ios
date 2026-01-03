//
//  RootView.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        if appState.currentUser != nil {
            DashboardScreen()
        } else {
            LoginScreen(appState: appState)
        }
    }
}

