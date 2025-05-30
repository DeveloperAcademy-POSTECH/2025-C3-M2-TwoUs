//
//  PostStartQuestionResponseDTO.swift
//  EKO-iOS
//
//  Created by mini on 5/30/25.
//

import Foundation

struct PostStartQuestionResponseDTO: Decodable {
    let success: Bool
    let sessionId: String
    let s3Key: String
}
