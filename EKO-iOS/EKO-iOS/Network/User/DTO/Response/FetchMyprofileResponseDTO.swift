//
//  FetchMyprofileResponseDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 6/4/25.
//

import Foundation

struct FetchMyprofileResponseDTO: Decodable {
    let userId: String
    let nickname: String
    let userAddCode: Int
    let userQrCodeUrl: String
}

