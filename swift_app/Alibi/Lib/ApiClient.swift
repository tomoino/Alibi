//
//  EventFetcher.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/08.
//

import Foundation

class ApiClient: ObservableObject {
    @Published var eventData: [Event] = []
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
    
    func updateEvent() {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        format.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        let event: Event = Event(id: 1,
//                                 time: "\(format.string(from: date)).000000Z",
                                 time: "2020-12-05 16:17:31.043239",
                              location: "リビング",
                              event: "昼食",
                              created_at: "2020-12-08T12:00+09:00",
                              updated_at: ""
                              )
        
        guard let url = URL(string: baseUrl + "/update/\(event.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
//        let postParameters = "Id=\(event.id)&Time=\(event.time)&Location=\(event.location)&Event=\(event.event)&CreatedAt=\(event.created_at)&UpdatedAt=\(event.updated_at)"
        let postParameters = "Id=\(event.id)&Location=\(event.location)&Event=\(event.event)"
        print(postParameters)
        
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
//
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//        let data = try encoder.encode(objs)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
               print("error is \(String(describing: error))")
               return
            }
//            if let data = data {
//                self.eventData = try! JSONDecoder().decode([Event].self, from: data)
//                print(self.eventData)
//            }
        })
        task.resume()
        
    }
}

//class ApiClient: ObservableObject {
//
//    // API
//    private let urlLink = "https://alibi-api.herokuapp.com/events"
//    // このプロパティに変更があった際にイベント発行
//    @Published var eventData: [Event] = []
//
//    init() {
//        fetchEventData()
//    }
//
//    func fetchEventData() {
//        let url: URL = URL(string: "https://alibi-api.herokuapp.com/events")!
//        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
//                    // コンソールに出力
//                    print("data: \(String(describing: data))")
//                    print("response: \(String(describing: response))")
//                    print("error: \(String(describing: error))")
//                    guard let data = data else { return }
//                    do{
//                        let decoder = JSONDecoder()
//                        self.eventData = try decoder.decode([Event].self, from: data)
//                    } catch {
//                        print(error)
//                    }
//                })
//                task.resume()
//    }
//
//
//    func fetchEventDataById() {
//        let url: URL = URL(string: "https://alibi-api.herokuapp.com/event/1")!
//        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
//                    // コンソールに出力
//                    print("data: \(String(describing: data))")
//                    print("response: \(String(describing: response))")
//                    print("error: \(String(describing: error))")
//                    do{
//                       let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
//                        print(jsonData) // Jsonの中身を表示
//                    } catch {
//                        print(error)
//                    }
//                })
//                task.resume()
//    }
//
//}
