//
//  TimelineView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/26.
//

import SwiftUI

struct TimelineView: View {
    @State private var page = 0// 初期値
    var date = [Int]()
    var pages: [DayTimeline] = []
    @ObservedObject var event_elements = EventElements()
    @ObservedObject var apiClient = ApiClient()
 
    init(){
        for j in [12, 1] {
            for i in 1 ... 31 {
                if (j == 12 && i < 11) || (j == 1 && i > 7) {
                    continue
                }

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
        let _h = CGFloat(69.15 * event_element.length / 60.0 - 8.0)
        let h = event_element.length >= 30 ? _h: (event_element.length >= 20 ? 20: 12)
        let toppad = event_element.length >= 30 ? 5: (event_element.length >= 20 ? 2.5: 0)
        // material design color: 300
        let COLORS: [String: Int] = ["プロ研":0xFFB74D, // Orange
                                     "回路理論":0x4FC3F7, // Light Blue
                                     "多変量解析":0x7986CB, // Indigo
                                     "ビジネス":0x4DB6AC, // Teal
                                     "電生実験":0xFFF176, // Yellow
                                     "OS":0xAED581, // Light Green
                                     "論文読み":0xe57373, //Red
                                     "開発環境構築":0xBA68C8, // Purple
                                     "入浴":0x9E9E9E,
                                     "食事":0x9E9E9E,
                                     "睡眠":0x9E9E9E,
                                     "インターン":0x9E9E9E,
                                     "外出":0x9E9E9E]
        // material design color: 300
        let FONT_COLORS: [String: Int] = ["プロ研":0xf44336,
                                     "回路理論":0xF06292,
                                     "多変量解析":0xBA68C8,
                                     "ビジネス":0x9575CD,
                                     "電生実験":0x7986CB,
                                     "OS":0x64B5F6,
                                     "論文読み":0x4FC3F7,
                                     "開発環境構築":0x4DD0E1,
                                     "入浴":0x4DB6AC,
                                     "食事":0x81C784,
                                     "睡眠":0xAED581,
                                     "インターン":0xDCE775,
                                     "外出":0xFFF176]
        
        HStack(alignment: .top) {
            Text(event_element.event)
            .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(Color(hex: 0xffffff))
            .frame(height: h, alignment: .top)
            .padding(EdgeInsets(top: CGFloat(toppad), leading: 10, bottom: 0, trailing: 10))
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .top)
//        .background(Color(red: 32/255, green: 36/255, blue: 38/255))
        .background(Color(hex: COLORS[event_element.event] ?? 0xdddddd, alpha: 0.7))
        .modifier(CardModifier(color: Color(hex: FONT_COLORS[event_element.event] ?? 0xffffff)))
        .padding(EdgeInsets(top: y, leading: 70, bottom: 0, trailing: 12))
    }
}

struct CardModifier: ViewModifier {
    let color: Color
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
