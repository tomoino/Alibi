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
            .padding(EdgeInsets(top: CGFloat(15), leading: 10, bottom: 0, trailing: 0))
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
        
        HStack(alignment: .top) {
            Text("合計作業時間")
            .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(Color(hex: 0xffffff))
            .frame(height: h, alignment: .top)
            .padding(EdgeInsets(top: CGFloat(15), leading: 10, bottom: 0, trailing: 0))
//            Text("\(hour):\(min)")
            Text("5:57")
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

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
