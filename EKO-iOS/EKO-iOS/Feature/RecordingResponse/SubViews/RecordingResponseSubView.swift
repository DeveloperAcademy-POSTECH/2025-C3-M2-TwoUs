//
//  RecordingResponseSubView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

struct FetchMyRequsetSubView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    @Binding var friends: [RecordingResponseViewModel.EKORequestFriend]
    @Binding var selectedRequestUserId: String?

    let type: EKOFriendsViewType = .response
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(friends) { friend in
                    EKOFriendsView(
                        type: type,
                        name: friend.senderNickname,
                        isSelected: selectedRequestUserId == friend.senderUserId
                    )
                    .padding(.vertical, 10)
                    .padding(.horizontal, 2)
                    .onTapGesture {
                        selectedRequestUserId = friend.senderUserId
                    }
                }
            }
        }
    }
}
