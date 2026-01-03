//
//  PublicDataScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 15/12/25.
//

import SwiftUI

struct PublicDataScreen: View {
    @EnvironmentObject var appState: AppState
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                
                NavigationLink(destination: ProjectScreen()) {
                    MenuButton(icon: "folder.fill", title: "Project", color: Color(UIColor.systemGreen))
                }

                if appState.currentUser?.isAdmin == true {
                    NavigationLink(destination: UserScreen()) {
                        MenuButton(icon: "folder.fill", title: "User", color: Color(UIColor.systemGreen))
                    }
                }

                // Add more buttons if needed
            }
            .padding()
        }
        .navigationTitle("Public Data").navigationBarTitleDisplayMode(.inline)
    }
}
