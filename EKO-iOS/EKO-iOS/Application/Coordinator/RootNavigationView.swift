//
//  RootNavigationView.swift
//  EKO-iOS
//
//  Created by mini on 5/28/25.
//

import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            MainView()
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .main: MainView()
                case .recordingRequest: RecordingRequestView()
                case .recordingResponse: RecordingResponseView()
                case .learningNote: LearningNoteView()
                case .profile: ProfileView()
                case .addFriend: AddFriendView()
                }
            }
        }
    }
}

#Preview {
    RootNavigationView()
        .environmentObject(AppCoordinator())
}
