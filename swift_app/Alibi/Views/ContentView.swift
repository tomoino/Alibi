//
//  ContentView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/08.
//

import SwiftUI
struct ContentView: View {
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
        HStack {
            Text("latitude: \(userLatitude)")
            Text("longitude: \(userLongitude)")
        }
        HStack {
            Text("rssi: (\(locationManager.beaconRssi1),\(locationManager.beaconRssi2),\(locationManager.beaconRssi3)), max rssi: (\(locationManager.beaconMaxRssi1),\(locationManager.beaconMaxRssi2),\(locationManager.beaconMaxRssi3))")
        }
//        NavigationView {
//            // 通信クラスの eventData プロパティを設定
//            List(apiClient.eventData) { event in
//                NavigationLink(destination: EventDetailView(eventData: event)) {
//                    EventRowView(eventData: event)
//                }
//            }
//            .navigationBarTitle(Text("Timeline"))
//        }
        TabView {
                    HomeView()
                        .tabItem {
                            VStack {
                                Image(systemName: "house.fill")
                                Text("Home")
                            }
                    }.tag(1)
                    TimelineView()
                        .tabItem {
                            VStack {
                                Image(systemName: "calendar")
                                Text("Timeline")
                            }
                    }.tag(2)
                    ReportView()
                        .tabItem {
                            VStack {
                                Image(systemName: "chart.pie.fill")
                                Text("Report")
                            }
                    }.tag(3)
                }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
