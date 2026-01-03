//
//  SwiftUI_logbookApp.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

import SwiftUI

@main
struct MyApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(
                    appState.theme == .system
                        ? nil
                        : (appState.theme == .dark ? .dark : .light)
                )
        }
    }
}
