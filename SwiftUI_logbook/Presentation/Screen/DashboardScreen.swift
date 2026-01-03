//
//  DashboardScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

import SwiftUI

struct DashboardScreen: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        TabView {
            // Personal Data
            NavigationStack {
                PersonalDataScreen()
            }
            .tabItem { Label("Personal Data", systemImage: "person.crop.circle") }

            // Public Data
            NavigationStack {
                PublicDataScreen()
            }
            .tabItem { Label("Public Data", systemImage: "person.2.circle.fill") }
            
            // Report
            NavigationStack {
                ReportScreen()
            }
            .tabItem { Label("Report", systemImage: "chart.bar.doc.horizontal") }
            
            // Settings
            NavigationStack {
                SettingsScreen()
            }
            .tabItem { Label("Settings", systemImage: "gear") }
        }
        // ⚡ Apply color scheme based on toggle
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
