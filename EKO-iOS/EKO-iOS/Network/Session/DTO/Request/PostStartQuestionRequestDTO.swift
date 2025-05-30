//
//  PostStartQuestionRequestDTO.swift
//  EKO-iOS
//
//  Created by mini on 5/30/25.
//

import Foundation

struct PostStartQuestionRequestDTO: Decodable {
    let senderUserId: String
    let receiverUserId: String
    let audioFileURL: URL
}
