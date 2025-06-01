//
//  PatchFeedbackNoteTitleResponseDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 5/31/25.
//

import Foundation

struct PatchFeedbackNoteTitleResponseDTO: Decodable {
    let message: String
    let sessionId: String
    let title: String
}
