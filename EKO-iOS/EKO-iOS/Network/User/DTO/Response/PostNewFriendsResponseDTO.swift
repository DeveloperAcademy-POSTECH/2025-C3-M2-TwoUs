//
//  PostNewFriendsResponseDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 6/4/25.
//

import Foundation

struct PostNewFriendsResponseDTO: Decodable {
    let message: String
    let userId: String
    let friendId: String
    let friendNickname: String
    let hasPendingQuestion: Bool
    let createdAt: Int
}
