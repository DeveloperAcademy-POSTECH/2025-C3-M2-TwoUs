//
//  PostRegisterResponseDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 6/4/25.
//

import Foundation

struct PostRegisterResponseDTO: Decodable {
    let userId: String
    let userAddcode: String
    let userQrcode: String
    let friendsList: [String] // 더미데이터입니다.
}
