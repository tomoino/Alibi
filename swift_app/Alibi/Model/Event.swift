//
//  Event.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/08.
//

import Foundation

struct Event: Decodable, Identifiable {
    var id: Int
    var time: String
    var location: String
    var event: String
    var created_at: String
    var updated_at: String
    var longitude: Double
    var latitude: Double

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case time = "Time"
        case location = "Location"
        case event = "Event"
        case created_at = "CreatedAt"
        case updated_at = "UpdatedAt"
        case longitude = "Longitude"
        case latitude = "Latitude"
    }
}

let mockEventsData: [Event]
    = [Event(id: 1,
             time: "2020-12-08T12:00+09:00",
             location: "リビング",
             event: "昼食",
             created_at: "2020-12-08T12:00+09:00",
             updated_at: "2020-12-08T12:00+09:00",
             longitude: 35.86873287946627,
             latitude: 139.4275921422954
             ),
    Event(id: 2,
             time: "2020-12-08T18:00+09:00",
             location: "風呂場",
             event: "入浴",
             created_at: "2020-12-08T18:00+09:00",
             updated_at: "2020-12-08T18:00+09:00",
             longitude: 35.86873287946627,
             latitude: 139.4275921422954
             ),
    Event(id: 3,
             time: "2020-12-08T20:00+09:00",
             location: "リビング",
             event: "夕食",
             created_at: "2020-12-08T20:00+09:00",
             updated_at: "2020-12-08T20:00+09:00",
             longitude: 35.86873287946627,
             latitude: 139.4275921422954
             )
]

class EventElement: ObservableObject, Identifiable {
    @Published var id = UUID()     // ユニークなIDを自動で設定
    @Published var event: String
    @Published var hour: Double
    @Published var min: Double
    @Published var length: Double

    init (event: String, hour: Double, min: Double, length:Double) {
        self.event = event
        self.hour = hour
        self.min = min
        self.length = length
    }
}

class EventElements: ObservableObject {
    @Published var eventElements: [Int:[Int:[Int:[EventElement]]]] = [2020:[12:[:]],2021:[1:[:]]] // [year][month][day][id]
}
