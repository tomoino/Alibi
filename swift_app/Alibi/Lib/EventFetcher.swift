//
//  EventFetcher.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/08.
//

import Foundation

class EventFetcher: ObservableObject {

    // API
    private let urlLink = "https://alibi-api.herokuapp.com/events"
    // このプロパティに変更があった際にイベント発行
    @Published var eventData: [Event] = []

    init() {
        fetchEventData()
    }

    func fetchEventData() {
        let url: URL = URL(string: "https://alibi-api.herokuapp.com/events")!
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                    // コンソールに出力
                    print("data: \(String(describing: data))")
                    print("response: \(String(describing: response))")
                    print("error: \(String(describing: error))")
                    guard let data = data else { return }
                    do{
                        let decoder = JSONDecoder()
                        self.eventData = try decoder.decode([Event].self, from: data)
                    } catch {
                        print(error)
                    }
                })
                task.resume()
    }
    
    
    func fetchEventDataById() {
        let url: URL = URL(string: "https://alibi-api.herokuapp.com/event/1")!
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                    // コンソールに出力
                    print("data: \(String(describing: data))")
                    print("response: \(String(describing: response))")
                    print("error: \(String(describing: error))")
                    do{
                       let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                        print(jsonData) // Jsonの中身を表示
                    } catch {
                        print(error)
                    }
                })
                task.resume()
    }

}
