//
//  TimelineView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/26.
//

import SwiftUI

struct TimelineView: View {
    @State private var page = 0 // 初期値
    let date = [Int](1...31)
    var pages: [DayTimeline] = []
 
    init(){
        for i in 1 ... 31 {
            pages.append(DayTimeline(day: i))
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
    var day: Int
    
    var body: some View {
        Text("12月\(day)日").font(.title)
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
                
                EventCard(event: "プロ研", hour: 0, min: 0, length: 10)
                EventCard(event: "プロ研", hour: 0, min: 10, length: 10)
                EventCard(event: "プロ研", hour: 0, min: 20, length: 10)
                EventCard(event: "プロ研", hour: 0, min: 30, length: 10)
                EventCard(event: "プロ研", hour: 0, min: 40, length: 10)
                EventCard(event: "プロ研", hour: 0, min: 50, length: 10)
//                EventCard(event: "プロ研", hour: 0, min: 50, length: 10)
                EventCard(event: "プロ研", hour: 2, min: 0, length: 20)
                EventCard(event: "プロ研", hour: 2, min: 20, length: 20)
                EventCard(event: "プロ研", hour: 2, min: 40, length: 20)
//                EventCard(event: "プロ研", hour: 4, min: 0, length: 10)
//                EventCard(event: "プロ研", hour: 5, min: 0, length: 60)
//                EventCard(event: "回路理論", hour: 7, min: 0, length: 120)
//                EventCard(event: "回路理論", hour: 9, min: 0, length: 60)
//                EventCard(event: "回路理論", hour: 11, min: 0, length: 60)
//                EventCard(event: "回路理論1", hour: 13, min: 0, length: 60)
//                EventCard(event: "回路理論2", hour: 15, min: 0, length: 60)
//                EventCard(event: "回路理論3", hour: 17, min: 0, length: 60)
//                EventCard(event: "回路理論", hour: 22, min: 0, length: 60)
            }
        }
    }
}

struct EventCard: View {
    var event: String
    var hour: Double
    var min: Double
    var length: Double
    
    var body: some View {
        let _y: CGFloat = -855+CGFloat(68.5 * (hour + min/60.0))
        let y = _y < 0 ? _y: CGFloat(138 * (hour - 12.0 + min/60.0))
        let _h = CGFloat(69.5 * length / 60.0 - 8.0)
//        let h = length < 30 ? CGFloat(12 * length / 10.0) : _h
        let h = length >= 30 ? _h: (length >= 20 ? 20: 12)
        let toppad = length >= 30 ? 5: (length >= 20 ? 2.5: 0)
        
        HStack(alignment: .center) {
                Text(event)
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
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    }
}

struct Timeline_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
