//
//  PostSendFeedbackDto.swift
//  EKO-iOS
//
//  Created by 성현 on 5/31/25.
//

import Foundation

struct PostStartFeedbackRequsetDTO: Encodable {
    let senderUserId: String
    let receiverUserId: String
    let sessionId: String
    let status: String
    let feedbackFileURL: URL?
}
