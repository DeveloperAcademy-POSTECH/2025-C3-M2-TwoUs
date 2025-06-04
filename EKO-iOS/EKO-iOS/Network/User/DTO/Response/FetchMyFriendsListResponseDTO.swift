//
//  GetMyFriendsListResponseDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 6/4/25.
//

import Foundation

struct FetchMyFriendsListResponseDTO: Decodable {
    let friendsList: [FetchFriendsList]
}

struct FetchFriendsList: Decodable {
    let firendNickname: String
    let createdAt: Int
    let hasPendingQuestion: Bool
    let userId: String
    let friendId: String
}
