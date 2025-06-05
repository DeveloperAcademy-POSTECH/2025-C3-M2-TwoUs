//
//  MainView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab: EKOTab = .question
    @EnvironmentObject private var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    EKOTabSelector(selected: $selectedTab)
                    Spacer().frame(width: 186)
                }
                .padding(.top, 32)
                
                Spacer()
                
                if selectedTab == .question {
                    RecordingRequestView()
                } else {
                    RecordingResponseView()
                }
                
                Spacer()
            }
        }
    }
}


#Preview {
    MainView()
}

