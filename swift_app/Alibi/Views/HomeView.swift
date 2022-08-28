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
    @ObservedObject var locationManager = LocationManager()
    
    var userLatitude: String {
        return "\(locationManager.lastLocation?.coordinate.latitude ?? 0)"
    }

    var userLongitude: String {
        return "\(locationManager.lastLocation?.coordinate.longitude ?? 0)"
    }

    init(){
        apiClient.getAllEvents()
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("latitude: \(userLatitude)")
                Text("longitude: \(userLongitude)")
            }
            HStack {
                Text("rssi: (\(locationManager.beaconRssi1),\(locationManager.beaconRssi2),\(locationManager.beaconRssi3)), max rssi: (\(locationManager.beaconMaxRssi1),\(locationManager.beaconMaxRssi2),\(locationManager.beaconMaxRssi3))")
            }
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
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

