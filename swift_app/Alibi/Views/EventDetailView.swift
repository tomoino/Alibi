//
//  EventDetailView.swift
//  Alibi
//
//  Created by 井上智裕 on 2020/12/08.
//

import SwiftUI

struct EventDetailView: View {
    var eventData: Event
    
    @State var inputEmail: String = ""
    @State var inputPassword: String = ""
    @ObservedObject var apiClient = ApiClient()
    
        var body: some View {
            NavigationView {
                VStack(alignment: .center) {
                    Text("SwiftUI App")
                        .font(.system(size: 48,
                                      weight: .heavy))

                    VStack(spacing: 24) {
                        TextField("Mail address", text: $inputEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 280)

                        SecureField("Password", text: $inputPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 280)

                    }
                    .frame(height: 200)

                    Button(action: {
                       print("Login処理")
                        apiClient.updateEvent(event: eventData)
                    },
                    label: {
                        Text("Login")
                            .fontWeight(.medium)
                            .frame(minWidth: 160)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.accentColor)
                            .cornerRadius(8)
                    })

                    Spacer()
                }
            }
        }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(eventData: mockEventsData[0])
    }
}
