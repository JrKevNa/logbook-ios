//
//  DailyReportRepository.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 10/12/25.
//

import SwiftUI

class DailyReportRepository {
    private let api: APIService
    
    init(api: APIService = .shared) {
        self.api = api
    }
    
    func fetchDailyReport(startDate: Date = Date(), endDate: Date = Date(), userId: String? = nil) async throws -> ([DailyReport]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateStringStartDate = formatter.string(from: startDate)
        let dateStringEndDate = formatter.string(from: endDate)
        
        let response = try await api.fetchDailyReport(startDate: dateStringStartDate, endDate: dateStringEndDate, userId: userId)
        return (response)
    }
    
}
