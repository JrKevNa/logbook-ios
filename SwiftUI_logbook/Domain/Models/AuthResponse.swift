//
//  AuthResponse.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

struct AuthResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
}
