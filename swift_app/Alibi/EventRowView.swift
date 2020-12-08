//
//  EventRowView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/08.
//

import SwiftUI

struct EventRowView: View {

    var eventData: Event

    var body: some View {
        VStack(alignment: .leading) {
            Text(eventData.event)
                .bold()
                .font(.headline)
                .lineLimit(2)
                .padding(Edge.Set.top, 8.0)
                .padding(Edge.Set.bottom, 12.0)
            HStack {
                Image(systemName: "calendar")
                    .imageScale(.medium)
                    .foregroundColor(.red)
                Text(eventData.time).font(.footnote)
            }.padding(Edge.Set.bottom, 6.0)
            HStack {
                Image(systemName: "person.fill")
                    .imageScale(.medium)
                    .foregroundColor(.red)
                Text("場所："+eventData.location ).font(.footnote)
            }.padding(Edge.Set.bottom, 6.0)
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .imageScale(.medium)
                    .foregroundColor(.red)
                Text(eventData.location)
                    .font(.footnote)
                    .lineLimit(3)
            }.padding(Edge.Set.bottom, 4.0)
            HStack {
                Spacer()
                Text("#" + eventData.created_at)
                    .foregroundColor(.blue)
                    .font(.caption)
                    .padding(Edge.Set.bottom, 8.0)
            }
        }
    }
}

struct EventRowView_Previews: PreviewProvider {
    static var previews: some View {
        EventRowView(eventData: mockEventsData[0])
    }
}
