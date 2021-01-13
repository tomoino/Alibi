//
//  Chart.swift
//  Alibi
//
//  Created by 井上智裕 on 2021/01/12.
//

import SwiftUI

struct ChartData {
    var id = UUID()
    var color : Color
    var percent : CGFloat
    var value : CGFloat
    var event : String
}

class ChartDataContainer : ObservableObject {
    @Published var chartData: [ChartData] =
        [ChartData(color: Color(hex: 0xFFB74D ), percent: 12.5, value: 0, event: "プロ研"),
         ChartData(color: Color(hex: 0x4FC3F7 ), percent: 12.5, value: 0, event: "回路理論"),
         ChartData(color: Color(hex: 0x7986CB ), percent: 12.5, value: 0, event: "多変量解析"),
         ChartData(color: Color(hex: 0x4DB6AC ), percent: 12.5, value: 0, event: "ビジネス"),
         ChartData(color: Color(hex: 0xFFF176 ), percent: 12.5, value: 0, event: "電生実験"),
         ChartData(color: Color(hex: 0xAED581 ), percent: 12.5, value: 0, event: "OS"),
         ChartData(color: Color(hex: 0xe57373 ), percent: 12.5, value: 0, event: "論文読み"),
         ChartData(color: Color(hex: 0xBA68C8 ), percent: 12.5, value: 0, event: "開発環境構築")]
    
//    [ChartData(color: Color(#colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)), percent: 8, value: 0),
//     ChartData(color: Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)), percent: 15, value: 0),
//     ChartData(color: Color(#colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)), percent: 32, value: 0),
//     ChartData(color: Color(#colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)), percent: 45, value: 0)]
//    init() {
//           calc()
//    }
    func calc(){
        var value : CGFloat = 0
        
        for i in 0..<chartData.count {
            value += chartData[i].percent
            chartData[i].value = value
        }
    }
}

struct DonutChart : View {
    @ObservedObject var charDataObj: ChartDataContainer
    @State var indexOfTappedSlice = -1
    var body: some View {
        VStack {
            ZStack {
                ForEach(0..<charDataObj.chartData.count) { index in
                    Circle()
                        .trim(from: index == 0 ? 0.0 : charDataObj.chartData[index-1].value/100,
                              to: charDataObj.chartData[index].value/100)
                        .stroke(charDataObj.chartData[index].color,lineWidth: 50)
                        .onTapGesture {
                            indexOfTappedSlice = indexOfTappedSlice == index ? -1 : index
                        }
                        .scaleEffect(index == indexOfTappedSlice ? 1.1 : 1.0)
                        .animation(.spring())
                }
                if indexOfTappedSlice != -1 {
                    Text(String(format: "%.2f", Double(charDataObj.chartData[indexOfTappedSlice].percent))+"%")
                        .font(.title)
                }
            }
            .frame(width: 200, height: 250)
            .padding()
            .onAppear() {
                self.charDataObj.calc()
            }
            
            var index: Int = 0
            ForEach(0..<charDataObj.chartData.count/2) { index in
                HStack {
                        
                        HStack {
                            
                            Text(charDataObj.chartData[index * 2].event)
                            .onTapGesture {
                                indexOfTappedSlice = indexOfTappedSlice == index * 2 ? -1 : index * 2
                            }
                            .font(indexOfTappedSlice == index * 2 ? .headline : .subheadline)
                            
//                            Text(String(format: "%.2f", Double(charDataObj.chartData[index].percent))+"%")
//                            .onTapGesture {
//                                indexOfTappedSlice = indexOfTappedSlice == index ? -1 : index
//                            }
//                            .font(indexOfTappedSlice == index ? .headline : .subheadline)
                                
                            RoundedRectangle(cornerRadius: 8)
                            .fill(charDataObj.chartData[index * 2].color)
                            .frame(width: 15, height: 15)
                        }
                        .padding(8)
                        .frame(width: 150, alignment: .trailing)
                
                
                            HStack {
                                
                                Text(charDataObj.chartData[index * 2 + 1].event)
                                .onTapGesture {
                                    indexOfTappedSlice = indexOfTappedSlice == index * 2 + 1 ? -1 : index * 2 + 1
                                }
                                .font(indexOfTappedSlice == index * 2 + 1 ? .headline : .subheadline)
                                
    //                            Text(String(format: "%.2f", Double(charDataObj.chartData[index].percent))+"%")
    //                            .onTapGesture {
    //                                indexOfTappedSlice = indexOfTappedSlice == index ? -1 : index
    //                            }
    //                            .font(indexOfTappedSlice == index ? .headline : .subheadline)
                                    
                                RoundedRectangle(cornerRadius: 8)
                                .fill(charDataObj.chartData[index * 2 + 1].color)
                                .frame(width: 15, height: 15)
                            }
                            .padding(8)
                            .frame(width: 150, alignment: .trailing)
                }// HStack
            }// ForEach
        }.padding(EdgeInsets(top: 25, leading: 0, bottom: 45, trailing: 0))  // ZStack
    }
}
