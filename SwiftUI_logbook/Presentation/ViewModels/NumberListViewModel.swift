//  NumberListViewModel.swift
//  InfiniteScroll
//
//  Created by Mohammad Azam on 9/1/21.
//

import SwiftUI

class NumberListViewModel: ObservableObject {
    
    @Published var numbers: [Int] = []
    
    func populateData(page: Int) {
        let pageSize = 10
        let start = (page - 1) * pageSize + 1
        let end = start + pageSize - 1
        
        let newNumbers = Array(start...end)
        
        // Simulate async delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.numbers.append(contentsOf: newNumbers)
        }
    }
    
    func shouldLoadData(id: Int) -> Bool {
        return id == numbers.count - 2
    }
    
}
