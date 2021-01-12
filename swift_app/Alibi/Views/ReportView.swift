//
//  ReportView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/26.
//

import SwiftUI

//struct ReportView: View {
//    var body: some View {
//        Text("This is Report.")
//    }
//}
//
//struct Report_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportView()
//    }
//}

struct ReportView: View {
    @State private var page = 0// 初期値
    var date = [Int]()
    var pages: [DayTimeline] = []
    @ObservedObject var event_elements = EventElements()
    @ObservedObject var apiClient = ApiClient()
 
    init(){
        apiClient.getReport(from_year: 2020, from_month: 12, from_day: 11, to_year:2021, to_month: 1, to_day: 7)
    }
    
    var body: some View {
        VStack () {
            Text("Report").font(.title)
//            ScrollView(.horizontal, showsIndicators: false) {
//                Picker("Page", selection: $page) {
//                    ForEach (0 ..< date.count) { num in
//                        Text(String(self.date[num]))
//                    }
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .padding(EdgeInsets(top: 20, leading: 12, bottom: 20, trailing: 12))
//            }
            
//            PageView(pages, currentPage: $page)
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
