//
//  GetFriendsProfileResponseDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 6/4/25.
//

import Foundation

struct FetchFriendsProfileResponseDTO: Decodable {
    let friendProfile: [FetchFriendProfile]
}

struct FetchFriendProfile: Decodable {
    let userId: String
    let nickname: String
}
