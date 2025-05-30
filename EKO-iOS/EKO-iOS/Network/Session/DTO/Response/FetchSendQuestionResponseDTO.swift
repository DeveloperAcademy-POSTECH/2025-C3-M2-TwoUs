//
//  FetchSendQuestionResponseDTO.swift
//  EKO-iOS
//
//  Created by mini on 5/30/25.
//

import Foundation

struct FetchSendQuestionResponseDTO: Decodable {
    let sessions: [Session]
}

struct Session: Decodable {
    let receiverUserId: String
    let sessionId: String
    let status: String
    let createdAt: Int
    let senderUserId: String
    let s3Key: String
    let title: String
}
