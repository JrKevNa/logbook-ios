//
//  ReportScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 10/12/25.
//

import SwiftUI

struct ReportScreen: View {
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                
                NavigationLink(destination: DailyReportScreen()) {
                    MenuButton(icon: "cube.box.fill", title: "Daily Report", color: Color(UIColor.systemOrange))
                }
                // Add more buttons if needed
                NavigationLink(destination: UserReportScreen()) {
                    MenuButton(icon: "cube.box.fill", title: "User Report", color: Color(UIColor.systemOrange))
                }
            }
            .padding()
        }
        .navigationTitle("Report").navigationBarTitleDisplayMode(.inline)
    }
}
