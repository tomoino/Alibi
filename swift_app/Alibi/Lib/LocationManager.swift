//
//  LocationManager.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/09.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {

    var beaconRegion : CLBeaconRegion!
    var beacon1: Int

    override init() {
        self.beacon1 = -100
        super.init()
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true; // バックグランドモードで使用する場合YESにする必要がある

        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
//        var trackLocationManager : CLLocationManager!
                // BeaconのUUIDを設定
        let uuid:UUID? = UUID(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")

        //Beacon領域を作成
        self.beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "net.noumenon-th")
        
        // 位置情報の認証チェック
        let status = CLLocationManager.authorizationStatus()
        if (status == .notDetermined) {
            print("許可、不許可を選択してない");
            // 常に許可するように求める
            locationManager.requestAlwaysAuthorization();
        }
        else if (status == .restricted) {
            print("機能制限している");
        }
        else if (status == .denied) {
            print("許可していない");
        }
        else if (status == .authorizedWhenInUse) {
            print("このアプリ使用中のみ許可している");
            locationManager.startUpdatingLocation();
        }
        else if (status == .authorizedAlways) {
            print("常に許可している");
            locationManager.startUpdatingLocation();
        }
    }

    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }

        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }

    }

    let objectWillChange = PassthroughSubject<Void, Never>()

    private let locationManager = CLLocationManager()
}

extension LocationManager: CLLocationManagerDelegate {

    //位置認証のステータスが変更された時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        print(#function, statusString)
        manager.startMonitoring(for: self.beaconRegion)
    }
    
    //観測の開始に成功すると呼ばれる
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //観測開始に成功したら、領域内にいるかどうかの判定をおこなう。→（didDetermineState）へ
        manager.requestState(for: self.beaconRegion)
    }
    
    //領域内にいるかどうかを判定する
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for inRegion: CLRegion) {
        switch (state) {
            case .inside: // すでに領域内にいる場合は（didEnterRegion）は呼ばれない
                manager.startRangingBeacons(in: beaconRegion)
                // →(didRangeBeacons)で測定をはじめる
                break

            case .outside:
                // 領域外→領域に入った場合はdidEnterRegionが呼ばれる
                break

            case .unknown:
                // 不明→領域に入った場合はdidEnterRegionが呼ばれる
                break

        }
    }
    
    //領域に入った時
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            // →(didRangeBeacons)で測定をはじめる
            manager.startRangingBeacons(in: self.beaconRegion)
    }

    //領域から出た時
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //測定を停止する
        manager.stopRangingBeacons(in: self.beaconRegion)
    }
    
    //領域内にいるので測定をする
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
            if(beacons.count > 0){
                for i in 0 ..< beacons.count {
                    let beacon = beacons[i]
                    let beaconUUID = beacon.proximityUUID;
                    let rssi = beacon.rssi;
                    print("UUID:\(beacon.proximityUUID), rssi: \(beacon.rssi)")
                    self.beacon1 = beacon.rssi
                }
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        print(#function, location)
        print("Location: \(self.beacon1)")
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        let apiClient = ApiClient()
        let event = Event(id: 1,
                 time: "",
                 location: "どこか",
                 event: "GPSのテスト",
                 created_at: "",
                 updated_at: "",
                 longitude: self.lastLocation?.coordinate.longitude ?? 0,
                 latitude: self.lastLocation?.coordinate.latitude ?? 0
                 )
        
//        if (minute % 10 == 0 && second == 0) {
          if (minute % 30 == 0 && second == 0 && hour > 7 && hour < 21) { // 一時的に時間制限をつけてデータを集める
            apiClient.createEvent(event: event)
        }
    }
}
