//
//  ContentView.swift
//  InfiniteScroll
//
//  Created by Mohammad Azam on 9/1/21.
//

import SwiftUI

struct ContentScreen: View {
    
    @StateObject private var numberListVM = NumberListViewModel()
    @State private var currentPage: Int = 1
    
    var body: some View {
        List(numberListVM.numbers, id: \.self) { number in
            Text("\(number)")
                .onAppear(perform: {
                    if numberListVM.shouldLoadData(id: number) {
                        currentPage += 1
                        numberListVM.populateData(page: currentPage)
                    }
                })
        }.onAppear(perform: {
            numberListVM.populateData(page: 1)
        })
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
