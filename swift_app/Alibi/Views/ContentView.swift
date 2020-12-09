//
//  ContentView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/08.
//

import SwiftUI

struct ContentView: View {
    // ObservableObject に準拠したクラスを監視
//    @ObservedObject var fetcher = ApiClient()
//    var eventData: [Event]
    @ObservedObject var apiClient = ApiClient()

    init(){
        apiClient.getAllEvents()
    }
    
    var body: some View {
        NavigationView {
            // 通信クラスの eventData プロパティを設定
            List(apiClient.eventData) { event in
                NavigationLink(destination: EventDetailView(eventData: event)) {
                    EventRowView(eventData: event)
                }
            }
            .navigationBarTitle(Text("Timeline"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
