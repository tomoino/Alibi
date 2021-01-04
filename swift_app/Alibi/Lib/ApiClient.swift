//
//  EventFetcher.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/08.
//

import Foundation

class ApiClient: ObservableObject {
    @Published var eventData: [Event] = []
    @Published var event_elements = EventElements()
    @Published var daily_events = [EventElement]()
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
                        
                        let event_categories = event.event.components(separatedBy: ",")
                        var category_counts: [String: Int] = [:]
                        
                        for item in event_categories {
                            category_counts[item] = (category_counts[item] ?? 0) + 1
                        }
                        var event_name = ""
                        var max_counts = 0
                        
                        for (key, value) in category_counts {
                            if value > max_counts {
                                event_name = key
                                max_counts = value
                            }
                        }
                        
                        // 配列にすでに要素がある場合
                        if event_elements.count > 0 {
                            let last_index = event_elements.count - 1
                            let last_event_element = event_elements[last_index]
                            
                            // 連続していたら
                            if (last_event_element.event == event_name){
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
