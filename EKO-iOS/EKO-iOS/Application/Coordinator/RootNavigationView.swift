//
//  RootNavigationView.swift
//  EKO-iOS
//
//  Created by mini on 5/28/25.
//

import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var isPressing: Bool = false
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Group {
                if UserDefaults.standard.string(forKey: "userId") != nil {
                    MainView()
                } else {
                    RegisterView()
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .main: MainView()
                case .recordingRequest: RecordingRequestView(isPressing: $isPressing)
                case .recordingResponse: RecordingResponseView(isPressing: $isPressing)
                case .learningNote: LearningNoteView()
                case .profile: ProfileView()
                case .addFriend: AddFriendView()
                case .register: RegisterView()
                }
            }
        }
    }}

#Preview {
    RootNavigationView()
        .environmentObject(AppCoordinator())
}
