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
    @State private var showNote = false
    
    var body: some View {
        ZStack {
            LearningNoteView()
                .offset(y: showNote ? 0 : UIScreen.main.bounds.height)
                .animation(.easeInOut, value: showNote)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if abs(value.translation.height) > abs(value.translation.width),
                               value.translation.height > 80 {
                                withAnimation {
                                    showNote = false
                                }
                            }
                        }
                )
                .zIndex(0)
            
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
            .offset(y: showNote ? -UIScreen.main.bounds.height : 0)
            .animation(.easeInOut, value: showNote)
            .zIndex(1)
            
            // Note View에서는 눌리지 않도록 하기
            if selectedTab == .question && !showNote {
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture().onEnded { value in
                            if abs(value.translation.height) > abs(value.translation.width),
                               value.translation.height < -80 {
                                withAnimation {
                                    showNote = true
                                }
                            }
                        }
                    )
            }
        }
    }
}

#Preview {
    MainView()
}
