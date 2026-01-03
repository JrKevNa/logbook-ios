//
//  UserReportRepository.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 12/12/25.
//

import SwiftUI

class UserReportRepository {
    private let api: APIService
    
    init(api: APIService = .shared) {
        self.api = api
    }
    
    func fetchUserReport(startDate: Date = Date(), endDate: Date = Date(), userId: String? = nil) async throws -> ([UserReport]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateStringStartDate = formatter.string(from: startDate)
        let dateStringEndDate = formatter.string(from: endDate)
        
        let response = try await api.fetchUserReport(startDate: dateStringStartDate, endDate: dateStringEndDate, userId: userId)
        return (response)
    }
    
}
