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
                VStack(spacing: 10) {
                    Divider()
                    ForEach(0..<24) {
                        Text("\($0):00")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 2, leading: 12, bottom: 10, trailing: 12))
                        Divider()
                    }
                    Spacer(minLength: 50)   // Viewの最下段にスペースを追加
                }
                .frame(maxWidth: .infinity) // スクロールの対象範囲を画面幅いっぱいにする為
                
                EventCard(event: "プロ研", hour: 5, min: 0, length: 60)
                EventCard(event: "回路理論", hour: 7, min: 0, length: 120)
//                    .padding(EdgeInsets(top: 2, leading: 60, bottom: 10, trailing: 12))
            }
        }
    }
}

struct EventCard: View {
    var event: String
    var hour: Int
    var min: Int
    var length: Int
    
    var body: some View {
        HStack(alignment: .center) {
            Text(event)
            .font(.system(size: 22, weight: .bold, design: .default))
            .foregroundColor(.white)
                .frame(height: 52*CGFloat(length/60))
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(red: 32/255, green: 36/255, blue: 38/255))
        .modifier(CardModifier())
        .padding(EdgeInsets(top: CGFloat(-662 + 52 * (hour + min/60)), leading: 70, bottom: 0, trailing: 12))
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 0)
    }
}

struct Timeline_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
