//
//  PostStartFeedbackResponseDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 5/31/25.
//

import Foundation

struct PostStartFeedbackResponseDTO: Decodable{
    let success: Bool
    let sessionId: String
}
