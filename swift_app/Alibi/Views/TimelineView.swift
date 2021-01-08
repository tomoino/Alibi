//
//  TimelineView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/26.
//

import SwiftUI

struct TimelineView: View {
    @State private var page = 13// 初期値
    var date = [Int]()
    var pages: [DayTimeline] = []
    @ObservedObject var event_elements = EventElements()
    @ObservedObject var apiClient = ApiClient()
 
    init(){
//        event_elements = apiClient.getTimelines()
        
        for j in [12, 1] {
            for i in 1 ... 31 {
                var k = 2020
                if j == 1 {
                    k = 2021
                }
                
                pages.append(DayTimeline(year: k, month: j, day: i))
                date.append(i)
            }
        }
    }
    
    var body: some View {
        VStack () {
            Text("Timeline").font(.title)
            ScrollView(.horizontal, showsIndicators: false) {
                Picker("Page", selection: $page) {
                    ForEach (0 ..< date.count) { num in
                        Text(String(self.date[num]))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(EdgeInsets(top: 20, leading: 12, bottom: 20, trailing: 12))
            }
            
            PageView(pages, currentPage: $page)
        }
    }
}

struct DayTimeline: View {
//    @ObservedObject var event_elements: EventElements
    var year: Int
    var month: Int
    var day: Int
    var weekday: String // 曜日
    
    @ObservedObject var apiClient = ApiClient()
    
    init (year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
        
        let year_s = year.description
        let month_s = month < 10 ? "0"+month.description : month.description
        let day_s = day < 10 ? "0"+day.description : day.description
        let s = year_s + month_s + day_s

        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        df.locale = Locale(identifier: "ja_JP")

        guard let d = df.date(from: s) else { fatalError() }
        guard let dc = df.calendar?.component(.weekday, from: d) else { fatalError() }

        self.weekday = df.shortWeekdaySymbols[dc - 1]
        
        apiClient.getDailyEvents(year: year, month: month, day: day)
    }
    
    
    var body: some View {
        Text(year.description+"年\(month)月\(day)日 (\(self.weekday))").font(.title)
        ScrollView(.vertical) {
            ZStack {
                // 時間軸
                VStack(spacing: 14) {
                    Divider()
                    ForEach(0..<24) {
                        Text("\($0):00")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 0, leading: 12, bottom: 20, trailing: 12))
                        Divider()
                    }
                    Spacer(minLength: 50)   // Viewの最下段にスペースを追加
                }
                .frame(maxWidth: .infinity) // スクロールの対象範囲を画面幅いっぱいにする為
                
                ZStack {
                    ForEach(apiClient.daily_events) { event_element in
                        VStack () {
                            EventCard(event_element: event_element)
                            Spacer(minLength: 50)
                        }
                    }
                }
            } // ZStack
        }
    }
}

struct EventCard: View {
    @ObservedObject var event_element: EventElement
    
    var body: some View {
        let y: CGFloat = CGFloat(68.7 * (event_element.hour + event_element.min/60.0))
        let _h = CGFloat(69.5 * event_element.length / 60.0 - 8.0)
        let h = event_element.length >= 30 ? _h: (event_element.length >= 20 ? 20: 12)
        let toppad = event_element.length >= 30 ? 5: (event_element.length >= 20 ? 2.5: 0)
        
        HStack(alignment: .top) {
            Text(event_element.event)
            .font(.system(size: 12, weight: .bold, design: .default))
            .foregroundColor(.white)
            .frame(height: h, alignment: .top)
            .padding(EdgeInsets(top: CGFloat(toppad), leading: 10, bottom: 0, trailing: 10))
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(red: 32/255, green: 36/255, blue: 38/255))
        .modifier(CardModifier())
        .padding(EdgeInsets(top: y, leading: 70, bottom: 0, trailing: 12))
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.white, lineWidth: 0.3)
            )
//            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    }
}

struct Timeline_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
