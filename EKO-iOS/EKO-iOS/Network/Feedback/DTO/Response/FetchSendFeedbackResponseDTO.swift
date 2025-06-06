//
//  fetchSendFeedback.swift
//  EKO-iOS
//
//  Created by 성현 on 5/31/25.
//

import Foundation

struct FetchSendFeedbackResponseDTO: Decodable {
    let sessions: [FetchSession]
}

struct FetchSession: Decodable {
    let receiverUserId: String
    let sessionId: String
    let status: String
    let createdAt: Int
    let senderUserId: String
    let s3Key: String
    let title: String
    let senderNickname: String
}
