//
//  RecordingRequestViewModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation

@MainActor
final class RecordingRequestViewModel: ObservableObject {
    @Published var friends: [EKOFriend] = []
    @Published var selectedReceiverUserId: String?

    struct EKOFriend: Identifiable, Equatable {
        let id = UUID()
        let friendUserId: String
        let name: String
        let isSended: Bool
    }

    func fetchMyFriendsList() async {
        do {
            let response = try await NetworkService.shared.userService.fetchMyFriendsList(userId: "userA123")
            let fetched = response.friends.map {
                EKOFriend(
                    friendUserId: $0.friendUserId,
                    name: $0.friendNickname,
                    isSended: $0.hasPendingQuestion
                )
            }
            self.friends = fetched
            self.selectedReceiverUserId = fetched.first?.friendUserId // 첫 친구 선택
        } catch {
            print("친구 목록 불러오기 실패: \(error.localizedDescription)")
        }
    }

    func sendQuestion(from url: URL) async {
        guard let receiverId = selectedReceiverUserId else {
            print("선택된 친구가 없습니다.")
            return
        }

        let model = PostStartQuestionRequestDTO(
            senderUserId: "userA123",
            receiverUserId: receiverId,
            audioFileURL: url
        )

        do {
            let result = try await NetworkService.shared.sessionService.postStartQuestion(model: model)
            print("postStartFeedback result: \(result)")
        } catch {
            print("postStartFeedback error: \(error)")
        }
    }
}



