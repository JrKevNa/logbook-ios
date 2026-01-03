//
//  UserRole.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 15/12/25.
//

import Foundation

struct UserRole: Codable, Equatable, Hashable {
    let id: String?
    let assignedAt: String
    let role: Role
}
