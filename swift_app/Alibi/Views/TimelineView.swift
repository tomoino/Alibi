//
//  TimelineView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/26.
//

import SwiftUI

struct TimelineView: View {
    @State private var page = 0 // 初期値
    let date = [Int](1...100)
    var pages: [DayTimeline] = []
 
    init(){
        for i in 1 ... 100 {
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
//                HStack {
//                    Week()
//                    Week()
//                    Week()
//                    Week()
//                }
                    Spacer()
                    List() {
                        Text("Hoge")
                        Text("Fuga")
                    }
                    Spacer()
                }
    }
}

struct DayTimeline: View {
    var day: Int
    
    var body: some View {
        Text(String(day))
    }
}

struct Timeline_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
