//
//  PostRegisterRequestDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 6/4/25.
//

import Foundation

struct PostRegisterRequestDTO: Encodable {
    let userId: String
    let nickname: String
    let snsEndpointArn: String
}
