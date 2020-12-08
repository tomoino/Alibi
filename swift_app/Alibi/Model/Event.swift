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

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case time = "Time"
        case location = "Location"
        case event = "Event"
        case created_at = "CreatedAt"
        case updated_at = "UpdatedAt"
    }
}

let mockEventsData: [Event]
    = [Event(id: 1,
             time: "2020-12-08T12:00+09:00",
             location: "リビング",
             event: "昼食",
             created_at: "2020-12-08T12:00+09:00",
             updated_at: "2020-12-08T12:00+09:00"
             ),
    Event(id: 2,
             time: "2020-12-08T18:00+09:00",
             location: "風呂場",
             event: "入浴",
             created_at: "2020-12-08T18:00+09:00",
             updated_at: "2020-12-08T18:00+09:00"
             ),
    Event(id: 3,
             time: "2020-12-08T20:00+09:00",
             location: "リビング",
             event: "夕食",
             created_at: "2020-12-08T20:00+09:00",
             updated_at: "2020-12-08T20:00+09:00"
             )
]
