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
    var beaconRssi1: Int
    var beaconRssi2: Int
    var beaconRssi3: Int
    var beaconMaxRssi1: Int
    var beaconMaxRssi2: Int
    var beaconMaxRssi3: Int

    override init() {
        self.beaconRssi1 = 0
        self.beaconRssi2 = 0
        self.beaconRssi3 = 0
        
        self.beaconMaxRssi1 = -1000
        self.beaconMaxRssi2 = -1000
        self.beaconMaxRssi3 = -1000
        
        super.init()
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true; // バックグランドモードで使用する場合YESにする必要がある

        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
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
                    print("minor:\(beacon.minor), rssi: \(beacon.rssi)")
                    
                    // 検知できたビーコンのフラグを立てる
                    if beacon.rssi != 0 {
                        if beacon.minor == 1000 && beacon.rssi > self.beaconMaxRssi1 {
                            self.beaconMaxRssi1 = beacon.rssi
                        }
                        if beacon.minor == 2000 && beacon.rssi > self.beaconMaxRssi2 {
                            self.beaconMaxRssi2 = beacon.rssi
                        }
                        if beacon.minor == 3000 && beacon.rssi > self.beaconMaxRssi3 {
                            self.beaconMaxRssi3 = beacon.rssi
                        }
                    }
                    
                    // debug用にrssiの値を保存する
                    if beacon.minor == 1000 {
                        self.beaconRssi1 = beacon.rssi
                    }
                    if beacon.minor == 2000 {
                        self.beaconRssi2 = beacon.rssi
                    }
                    if beacon.minor == 3000 {
                        self.beaconRssi3 = beacon.rssi
                    }
                }
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        print(#function, location)
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        if (minute % 10 == 0 && second == 0 && hour > 11 && hour < 23) { // 10分間隔で実行 // 一時的に12〜22.5時まで
            let apiClient = ApiClient()
            var event = Event(id: 1,
                     time: "",
                     location: "",
                     event: "Beaconのテスト",
                     created_at: "",
                     updated_at: "",
                     longitude: self.lastLocation?.coordinate.longitude ?? 0,
                     latitude: self.lastLocation?.coordinate.latitude ?? 0
                     )
        
            let maxRssis = [self.beaconMaxRssi1,self.beaconMaxRssi2,self.beaconMaxRssi3]
            let maxRssiValue = maxRssis.max() ?? 0
            if maxRssiValue > -1000 { // beaconが検出された場合
                let maxRssiIndex = maxRssis.firstIndex(of: maxRssiValue) ?? 0
                let roomNames = ["自室","リビング","浴室"]
                event.location = roomNames[maxRssiIndex]
                print(event.location)
            } else {
                event.location = "自宅外"
                // GPSから場所名を取得する処理
            }
            
            apiClient.createEvent(event: event)
            
            // beaconの値初期化
            self.beaconMaxRssi1 = -1000
            self.beaconMaxRssi2 = -1000
            self.beaconMaxRssi3 = -1000
        }
    }
}
