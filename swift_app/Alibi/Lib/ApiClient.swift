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
    
    func getDailyEvents(year: Int, month: Int, day: Int) -> [EventElement] {
        var _events = [Event]()
        
        let event_elements: [EventElement] = [
            EventElement(event: "プロ研", hour: 0, min: 40, length: 10),
            EventElement(event: "プロ研", hour: 0, min: 50, length: 10),
            EventElement(event: "プロ研aaa", hour: 3, min: 0, length: 60),
            EventElement(event: "プロ研bbbbb", hour: 5, min: 0, length: 60),
        ]
        
        guard let url = URL(string: baseUrl + "/events?from=\(year)-\(month)-\(day)_00:00:00&to=\(year)-\(month)-\(day)_23:59:59") else { return event_elements}
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let data = data {
                _events = try! JSONDecoder().decode([Event].self, from: data)
                print("\(year)-\(month)-\(day)")
                print(_events)
            }
        })
        task.resume()
        
        return event_elements
    }
    
    func getTimelines() -> EventElements {
        let event_elements = EventElements()
        
        for j in [12, 1] {
            for i in 1 ... 31 {
                var k = 2020
                if j == 1 {
                    k = 2021
                }
                
                event_elements.eventElements[k]?[j]?[i] = self.getDailyEvents(year: k, month: j, day: i)
            }
        }
        
        return event_elements        
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
