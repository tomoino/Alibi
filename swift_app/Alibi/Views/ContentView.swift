//
//  ContentView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/08.
//

import SwiftUI
struct ContentView: View {    
    var body: some View {
        TabView {
//            HomeView()
//            .tabItem {
//                VStack {
//                    Image(systemName: "house.fill")
//                    Text("Home")
//                }
//            }.tag(1)
            
            TimelineView()
            .tabItem {
                VStack {
                    Image(systemName: "calendar")
                    Text("Timeline")
                }
            }.tag(1)
            
            ReportView()
            .tabItem {
                VStack {
                    Image(systemName: "chart.pie.fill")
                    Text("Report")
                }
            }.tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
