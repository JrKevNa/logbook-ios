//
//  Untitled.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 03/12/25.
//

import SwiftUI

struct PersonalDataScreen: View {
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                
                NavigationLink(destination: LogbookScreen()) {
                    MenuButton(icon: "book.fill", title: "Logbook", color: Color(UIColor.systemOrange))
                }

                NavigationLink(destination: ToDoListScreen()) {
                    MenuButton(icon: "checkmark.square.fill", title: "To Do List", color: Color(UIColor.systemBlue))
                }

//                NavigationLink(destination: ProjectScreen()) {
//                    MenuButton(icon: "folder.fill", title: "Project", color: Color(UIColor.systemGreen))
//                }

                NavigationLink(destination: ContentScreen()) {
                    MenuButton(icon: "doc.text.fill", title: "Content", color: Color(UIColor.systemPurple))
                }
                
                // Add more buttons if needed
            }
            .padding()
        }
        .navigationTitle("Personal Data").navigationBarTitleDisplayMode(.inline)
    }
}
