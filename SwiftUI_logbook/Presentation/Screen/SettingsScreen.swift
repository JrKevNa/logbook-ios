//
//  SettingScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 03/12/25.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Username Header as tappable row
                if let username = appState.currentUser?.username {
                    Section {
                        NavigationLink(destination: ProfileScreen(appState: appState)) {
                            HStack {
                                Text("Logged in as")
                                Spacer()
                                Text(username)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }

                // MARK: - Theme Picker
                Section("Theme") {
                    Picker("Theme", selection: $appState.theme) {
                        Text("System").tag(AppTheme.system)
                        Text("Light").tag(AppTheme.light)
                        Text("Dark").tag(AppTheme.dark)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: appState.theme) {
                        appState.saveTheme(appState.theme)
                    }
                }

                // MARK: - Logout Button
                Section {
                    Button(role: .destructive) {
                        appState.logout()
                    } label: {
                        Text("Log Out")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
