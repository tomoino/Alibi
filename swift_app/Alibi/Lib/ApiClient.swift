//
//  EventFetcher.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/08.
//

import Foundation
import SwiftUI

class ApiClient: ObservableObject {
    @Published var eventData: [Event] = []
    @Published var event_elements = EventElements()
    @Published var daily_events = [EventElement]()
    @Published var report: [String:Int] = [:]
    @Published var report_chart: ChartDataContainer = ChartDataContainer()
    
    private var baseUrl = "https://alibi-api.herokuapp.com"
    
    func getAllEvents() {
        guard let url = URL(string: baseUrl + "/events") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let data = data {
                self.eventData = try! JSONDecoder().decode([Event].self, from: data)
                print(self.eventData)
            }
        })
        task.resume()
    }
    
    func getDailyEvents(year: Int, month: Int, day: Int) {
        var _events = [Event]()
        self.daily_events = []
        var event_elements = [EventElement]()
        
        guard let url = URL(string: baseUrl + "/events?from=\(year)-\(month)-\(day)_00:00:00&to=\(year)-\(month)-\(day)_23:59:59") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let data = data {
                _events = try! JSONDecoder().decode([Event].self, from: data)
                
                var sleep_flag = 0 // 睡眠フラグ
                let CATEGORIES = ["プロ研","回路理論","多変量解析","ビジネス","電生実験","OS","論文読み","開発環境構築"]
                let REAL_EVENTS = ["入浴","食事","睡眠","インターン","外出"]
                
                for _event in _events {
                    var event = _event
                    
                    // 時間情報
                    let t1 = event.time.components(separatedBy: "T")
                    let t2 = t1[1].components(separatedBy: ":")
                    let hour = Double(t2[0])!
                    let min = Double(t2[1])!
                    
                    if event.event.isEmpty {
                        // 推論処理
                        // ルールベース
                        if (event.longitude < 139.44500 && event.latitude > 35.860000) { // 自宅
                            if (event.location == "浴室") { // 浴室にいるなら入浴と判定
                                event.event = "入浴"
                            } else if (event.location == "リビング") { // リビングにいるなら食事と判定
                                event.event = "食事"
                            } else if ((event.location == "自室" && hour < 5) || (sleep_flag == 1)) { // 食事前かつ自室にいるかつ5時前　または　睡眠フラグがたっているとき
                                event.event = "睡眠"
                                sleep_flag = 1
                            }
                        } else if (event.longitude > 139.76000 && event.latitude < 35.700000) {
                            event.event = "インターン"
                        } else {
                            event.event = "外出"
                        }
                        
                        // 推測してもなおemptyなら
//                        if event.event.isEmpty {
//                            flag = 0
//                        }
                    }
                    
                    if !event.event.isEmpty {
                        if (sleep_flag == 1 && event.event != "睡眠") { // 睡眠中に別のeventが挟まった場合
                            sleep_flag = 0
                            
                            if (hour < 5) { // 5時前　の場合、まだ入眠していなかった可能性
                                event_elements.removeLast() // 直前の睡眠eventを削除
                            }
                        }
                        
                        var event_name = ""
                        // ルールベースで推定した場合
                        if (REAL_EVENTS.contains(event.event)) {
                            event_name = event.event
                        } else { // 閲覧サイトから推定した作業内容がある場合
                        
                            let event_categories = event.event.components(separatedBy: ",")
                            let pred_vec = event_categories.map{Double($0)!}
                            
                            let max_num = pred_vec.max()
                            let max_idx = pred_vec.firstIndex(of: max_num ?? 0)!
                           
                            event_name = CATEGORIES[max_idx]
                        }
                        
                        // 配列にすでに要素がある場合
                        if event_elements.count > 0 {
                            let last_index = event_elements.count - 1
                            let last_event_element = event_elements[last_index]
                            
                            // 連続していたら
                            if (last_event_element.event == event_name && (hour*60+min) - (last_event_element.hour*60+last_event_element.min+last_event_element.length) <= 120){
                                event_elements[last_index].length = hour * 60 + min - (last_event_element.hour * 60 + last_event_element.min) + 10
                            } else {
                                event_elements.append(EventElement(event: event_name, hour: hour, min: min, length: 10))
                            }
                        } else {
                            event_elements.append(EventElement(event: event_name, hour: hour, min: min, length: 10))
                        }
                        
                        // eventがあったため連続フラグを立てる
//                        flag = 1
                    } // event is not empty
                }
                
                for event_element in event_elements {
                    self.daily_events.append(event_element)
                }
            }
        })
        task.resume()
    }
    
    func getReport(from_year: Int, from_month: Int, from_day: Int, to_year: Int, to_month: Int, to_day: Int) {
        var _events = [Event]()
        self.report = ["プロ研":0,"回路理論":0,"多変量解析":0,"ビジネス":0,"電生実験":0,"OS":0,"論文読み":0,"開発環境構築":0,"入浴":0,"食事":0,"睡眠":0,"インターン":0,"外出":0]
        var event_elements = [EventElement]()
        var daily_event_elements = [EventElement]()
        
        guard let url = URL(string: baseUrl + "/events?from=\(from_year)-\(from_month)-\(from_day)_00:00:00&to=\(to_year)-\(to_month)-\(to_day)_23:59:59") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let data = data {
                _events = try! JSONDecoder().decode([Event].self, from: data)
                
                var sleep_flag = 0 // 睡眠フラグ
                let CATEGORIES = ["プロ研","回路理論","多変量解析","ビジネス","電生実験","OS","論文読み","開発環境構築"]
                let REAL_EVENTS = ["入浴","食事","睡眠","インターン","外出"]
                
                var prev_day = 0
                
                for _event in _events {
                    var event = _event
                    
                    // 時間情報
                    let t1 = event.time.components(separatedBy: "T")
                    let t2 = t1[1].components(separatedBy: ":")
                    let hour = Double(t2[0])!
                    let min = Double(t2[1])!
                    let t3 = t1[0].components(separatedBy: "-")
                    let target_day = Int(t3[2])!
                    
                    // 日が変わったら
                    if target_day != prev_day {
                        daily_event_elements = []
                        sleep_flag = 0
                        prev_day = target_day
                    }
                    
                    if event.event.isEmpty {
                        // 推論処理
                        // ルールベース
                        if (event.longitude < 139.44500 && event.latitude > 35.860000) { // 自宅
                            if (event.location == "浴室") { // 浴室にいるなら入浴と判定
                                event.event = "入浴"
                            } else if (event.location == "リビング") { // リビングにいるなら食事と判定
                                event.event = "食事"
                            } else if ((event.location == "自室" && hour < 5) || (sleep_flag == 1)) { // 食事前かつ自室にいるかつ5時前　または　睡眠フラグがたっているとき
                                event.event = "睡眠"
                                sleep_flag = 1
                            }
                        } else if (event.longitude > 139.76000 && event.latitude < 35.700000) {
                            event.event = "インターン"
                        } else {
                            event.event = "外出"
                        }
                    }
                    
                    if !event.event.isEmpty {
                        if (sleep_flag == 1 && event.event != "睡眠") { // 睡眠中に別のeventが挟まった場合
                            sleep_flag = 0
                            
                            if (hour < 5) { // 5時前　の場合、まだ入眠していなかった可能性
                                event_elements.removeLast() // 直前の睡眠eventを削除
                                daily_event_elements.removeLast() // 直前の睡眠eventを削除
                            }
                        }
                        
                        var event_name = ""
                        // ルールベースで推定した場合
                        if (REAL_EVENTS.contains(event.event)) {
                            event_name = event.event
                        } else { // 閲覧サイトから推定した作業内容がある場合
                        
                            let event_categories = event.event.components(separatedBy: ",")
                            let pred_vec = event_categories.map{Double($0)!}
                            
                            let max_num = pred_vec.max()
                            let max_idx = pred_vec.firstIndex(of: max_num ?? 0)!
                           
                            event_name = CATEGORIES[max_idx]
                        }
                        
                        // 配列にすでに要素がある場合
                        if daily_event_elements.count > 0 {
                            let last_index = event_elements.count - 1
                            let last_event_element = event_elements[last_index]
                            let daily_last_index = daily_event_elements.count - 1
                            let daily_last_event_element = daily_event_elements[daily_last_index]
                            
                            // 連続していたら
                            if (daily_last_event_element.event == event_name && (hour*60+min) - (daily_last_event_element.hour*60+daily_last_event_element.min+daily_last_event_element.length) <= 120){
                                event_elements[last_index].length = hour * 60 + min - (last_event_element.hour * 60 + last_event_element.min) + 10
                                daily_event_elements[daily_last_index].length = hour * 60 + min - (daily_last_event_element.hour * 60 + daily_last_event_element.min) + 10
                            } else {
                                event_elements.append(EventElement(event: event_name, hour: hour, min: min, length: 10))
                                daily_event_elements.append(EventElement(event: event_name, hour: hour, min: min, length: 10))
                            }
                        } else {
                            event_elements.append(EventElement(event: event_name, hour: hour, min: min, length: 10))
                            daily_event_elements.append(EventElement(event: event_name, hour: hour, min: min, length: 10))
                        }
                    } // event is not empty
                }
                
                var length_sum = 0
                for event_element in event_elements {
                    self.report[event_element.event]! += Int(event_element.length)
                }
                
                for category in CATEGORIES {
                    length_sum += self.report[category]!
                }
                self.report["SUM_HOUR"] = length_sum/60
                self.report["SUM_MIN"] = length_sum - Int(length_sum/60) * 60
                
                print(self.report)
                
                
                self.report_chart.chartData = []
                
                let COLORS: [String: Int] = ["プロ研":0xFFB74D, // Orange
                                             "回路理論":0x4FC3F7, // Light Blue
                                             "多変量解析":0x7986CB, // Indigo
                                             "ビジネス":0x4DB6AC, // Teal
                                             "電生実験":0xFFF176, // Yellow
                                             "OS":0xAED581, // Light Green
                                             "論文読み":0xe57373, //Red
                                             "開発環境構築":0xBA68C8, // Purple
                                             "入浴":0x9E9E9E,
                                             "食事":0x9E9E9E,
                                             "睡眠":0x9E9E9E,
                                             "インターン":0x9E9E9E,
                                             "外出":0x9E9E9E]
                
                for category in CATEGORIES {
                    let percent = CGFloat(Double(self.report[category]!) / Double(length_sum) * 100.0)
                    self.report_chart.chartData.append(ChartData(color: Color(hex: COLORS[category] ?? 0xffffff), percent: percent, value: 0, event: category))
                }
            }
        })
        task.resume()
    }
    
    func updateEvent(event: Event) {
        guard let url = URL(string: baseUrl + "/update/\(event.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let postParameters = "Id=\(event.id)&Location=\(event.location)&Event=\(event.event)&Latitude=\(event.latitude)&Longitude=\(event.longitude)"
        print(postParameters)
        
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
               print("error is \(String(describing: error))")
               return
            }
        })
        task.resume()
    }
    
    func createEvent(event: Event) {
        guard let url = URL(string: baseUrl + "/create") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let postParameters = "Location=\(event.location)&Event=\(event.event)&Latitude=\(event.latitude)&Longitude=\(event.longitude)"
        print(postParameters)
        
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
               print("error is \(String(describing: error))")
               return
            }
        })
        task.resume()
    }
}
