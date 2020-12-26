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
                }
    }
}

struct Timeline_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
