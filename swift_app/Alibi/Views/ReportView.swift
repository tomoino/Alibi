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
            ReportCard(apiClient:apiClient)
            PieChart(apiClient:apiClient)
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

struct ReportCard: View {
    @ObservedObject var apiClient: ApiClient
    
    var body: some View {
        let y: CGFloat = 0
        let h: CGFloat = 40
        
        HStack(alignment: .top) {
            Text("合計作業時間")
            .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(Color(hex: 0xffffff))
            .frame(height: h, alignment: .top)
            .padding(EdgeInsets(top: CGFloat(15), leading: 20, bottom: 0, trailing: 0))
            
            Text("\(apiClient.report["SUM_HOUR"] ?? 0):\(apiClient.report["SUM_MIN"] ?? 0):00")
            .font(.system(size: 30, weight: .bold, design: .default))
                .foregroundColor(Color(hex: 0xFFB74D))
            .frame(height: h, alignment: .top)
            .padding(EdgeInsets(top: CGFloat(10), leading: 10, bottom: 0, trailing: 10))
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(red: 32/255, green: 36/255, blue: 38/255))
//        .background(Color(hex: 0x666666))
        .modifier(CardModifier(color: Color.white))
        .padding(EdgeInsets(top: y, leading: 20, bottom: 0, trailing: 20))
    }
}

struct PieChart: View {
    @ObservedObject var apiClient: ApiClient
    
    var body: some View {
        let y: CGFloat = 0
        let h: CGFloat = 550
        
        VStack(alignment: .leading) {
            Text("作業時間割合")
            .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(Color(hex: 0xffffff))
            .frame(height: 20, alignment: .top)
            .padding(EdgeInsets(top: CGFloat(15), leading: 5, bottom: 0, trailing: 0))
            
            DonutChart(charDataObj: apiClient.report_chart)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color(red: 32/255, green: 36/255, blue: 38/255))
//        .background(Color(hex: 0x666666))
        .modifier(CardModifier(color: Color.white))
        .padding(EdgeInsets(top: y, leading: 20, bottom: 0, trailing: 20))
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
