//
//  MenuButton.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 03/12/25.
//

import SwiftUI

struct MenuButton: View {
    var icon: String
    var title: String
    var color: Color = .accentColor // default color (optional)

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(color)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.5), radius: 6, x: 0, y: 3)
    }
}
