//
//  PostNewFriendsRequestDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 6/4/25.
//

import Foundation

struct PostNewFriendsRequestDTO: Encodable{
    let myUserId: String
    let friendUserId: String
    let myNickname: String
    let friendNickname: String
}
