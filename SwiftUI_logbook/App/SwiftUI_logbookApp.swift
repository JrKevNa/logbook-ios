//
//  SwiftUI_logbookApp.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

import GoogleSignIn
import SwiftUI

@main
struct MyApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .environmentObject(appState)
                .preferredColorScheme(
                    appState.theme == .system
                        ? nil
                        : (appState.theme == .dark ? .dark : .light)
                )
        }
    }
}
