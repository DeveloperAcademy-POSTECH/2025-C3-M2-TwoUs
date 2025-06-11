//
//  FetchFeedbackNotesResponseDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 5/31/25.
//

import Foundation

struct FetchFeedbackNotesResponseDTO: Decodable {
    let notes: [Note]
}

struct Note: Codable {
    let sessionId: String
    let receiverId: String
    let senderId: String
    let feedbackTimestamp: Int
    let status: String
    let feedbackS3Key: String?
    let createdAt: Int
    let isFavorite: Bool
    let s3Key: String
    let title: String
}
