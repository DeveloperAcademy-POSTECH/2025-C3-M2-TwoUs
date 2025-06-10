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
    @State private var isPressing = false
    
    var body: some View {
        ZStack {
            if isPressing {
                switch selectedTab {
                case .question: Color.supOrange3.ignoresSafeArea()
                case .answer: Color.supBlue4.ignoresSafeArea()
                }
            } else {
                LinearGradient(
                    colors: [Color.supOrange3, Color.supBlue4],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            
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
                        .opacity(isPressing ? 0 : 1)
                    Spacer().frame(width: 186)
                }
                .padding(.top, 32)
                
                Spacer()
                
                if selectedTab == .question {
                    RecordingRequestView(isPressing: $isPressing)
                } else {
                    RecordingResponseView(isPressing: $isPressing)
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
