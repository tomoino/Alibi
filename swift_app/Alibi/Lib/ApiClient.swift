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
        
//        self.event_elements.eventElements[year]?[month]?[day] = [
//            EventElement(event: "プロ研", hour: 0, min: 40, length: 10),
//            EventElement(event: "プロ研", hour: 0, min: 50, length: 10),
//            EventElement(event: "プロ研aaa", hour: 3, min: 0, length: 60),
//        ]
        self.daily_events = [
//            EventElement(event: "プロ研", hour: 0, min: 00, length: 60),
//            EventElement(event: "プロ研", hour: 3, min: 00, length: 60),
        ]
        
        guard let url = URL(string: baseUrl + "/events?from=\(year)-\(month)-\(day)_00:00:00&to=\(year)-\(month)-\(day)_23:59:59") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let data = data {
                _events = try! JSONDecoder().decode([Event].self, from: data)
                print("\(year)-\(month)-\(day)")
//                print(_events)
                for event in _events {
                    if !event.event.isEmpty {
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
                        
                        let t1 = event.time.components(separatedBy: "T")
                        let t2 = t1[1].components(separatedBy: ":")
                        self.daily_events.append(EventElement(event: event_name, hour: Double(t2[0]) ?? 0, min: Double(t2[1]) ?? 0, length: 10))
                        print(event)
                    }
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
