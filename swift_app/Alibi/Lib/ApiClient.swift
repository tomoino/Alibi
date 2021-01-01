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
    
    func getDailyEvents(month: Int, day: Int) -> [EventElement] {
        let event_elements: [EventElement] = [
            EventElement(event: "プロ研", hour: 0, min: 40, length: 10),
            EventElement(event: "プロ研", hour: 0, min: 50, length: 10),
            EventElement(event: "プロ研aaa", hour: 3, min: 0, length: 60),
            EventElement(event: "プロ研bbbbb", hour: 5, min: 0, length: 60),
        ]
//        guard let url = URL(string: baseUrl + "/events") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
//            if let data = data {
//                self.eventData = try! JSONDecoder().decode([Event].self, from: data)
//                print(self.eventData)
//            }
//        })
//        task.resume()
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
