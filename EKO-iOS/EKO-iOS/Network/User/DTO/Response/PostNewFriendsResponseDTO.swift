//
//  PostNewFriendsResponseDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 6/4/25.
//

import Foundation

struct PostNewFriendsResponseDTO: Decodable {
    let message: String
    let myFriendItem: FriendItem

    struct FriendItem: Decodable {
        let userId: String
        let friendUserId: String
        let friendNickname: String
        let hasPendingQuestion: Bool
        let createdAt: Int
    }
}
