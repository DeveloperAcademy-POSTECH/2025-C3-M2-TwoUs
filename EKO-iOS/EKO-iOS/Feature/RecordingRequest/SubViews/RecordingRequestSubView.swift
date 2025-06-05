//
//  RecordingRequestSubViews.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

struct FetchMyFriendsSubView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    @Binding var friends: [RecordingRequestViewModel.EKOFriend]
    @Binding var selectedReceiverUserId: String?

    let type: EKOFriendsViewType = .request

    var body: some View {
        HStack(spacing: 12) {
            Button {
                coordinator.path.append(AppRoute.addFriend)
            } label: {
                Image(systemName: "plus")
                    .frame(width: 31, height: 31)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .foregroundColor(.mainOrange)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1
                        )
                    )
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(friends) { friend in
                        EKOFriendsView(
                            type: type,
                            name: friend.name,
                            isSelected: selectedReceiverUserId == friend.friendUserId,
                            isSended: friend.isSended
                        )
                        .padding(.vertical, 10)
                        .padding(.horizontal, 2)
                        .onTapGesture {
                            selectedReceiverUserId = friend.friendUserId
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
