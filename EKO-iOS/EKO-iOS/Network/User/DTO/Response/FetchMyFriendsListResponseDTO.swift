//
//  GetMyFriendsListResponseDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 6/4/25.
//

import Foundation

struct FetchMyFriendsListResponseDTO: Decodable {
    let friends: [FetchFriendsList]
}

struct FetchFriendsList: Decodable {
    let friendNickname: String
    let createdAt: Int
    let hasPendingQuestion: Bool
    let userId: String
    let friendUserId: String
}
