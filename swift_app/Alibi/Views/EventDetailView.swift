//
//  EventDetailView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/08.
//

import SwiftUI

struct EventDetailView: View {
    var eventData: Event    // From ListView(静的モデル)
    @State private var zoomValue = 0.01

    var body: some View {
        ScrollView {
            
        }
        .navigationBarTitle("Event Detail", displayMode: .inline)
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(eventData: mockEventsData[0])
    }
}
