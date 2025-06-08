//
//  LearningNoteModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation

struct LearningNote: Identifiable {
    var id: String { sessionId }
    
    let sessionId: String
    let receiverId: String
    let senderId: String
    let status: String
    let feedbackS3Key: String?
    let createdAt: Int           // 밀리초 그대로 사용
    var isFavorite: Bool
    let s3Key: String
    var title: String
    var voice1: String? = nil
    var voice2: String? = nil
}
