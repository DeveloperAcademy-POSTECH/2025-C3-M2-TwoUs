//
//  MainView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

enum MainTab {
    case request
    case response
}

struct MainView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    
    @State private var selectedTab: MainTab = .request
    
    var body: some View {
        VStack {
            Picker("선택", selection: $selectedTab) {
                Text("요청").tag(MainTab.request)
                Text("응답").tag(MainTab.response)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 16)

            Spacer().frame(height: 16)

            Group {
                switch selectedTab {
                case .request:
                    RecordingRequestView()
                case .response:
                    RecordingResponseView()
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    MainView()
}
