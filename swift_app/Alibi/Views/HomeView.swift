//
//  HomeView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/26.
//


import SwiftUI

struct HomeView: View {
    // ObservableObject に準拠したクラスを監視
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
            .navigationBarTitle(Text("データの一覧"))
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

