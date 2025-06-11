//
//  PostAppleSignupRequestDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 6/11/25.
//

import Foundation

struct PostAppleSignupRequestDTO: Codable {
    let idToken: String
    let nickname: String
    let deviceToken: String
}
