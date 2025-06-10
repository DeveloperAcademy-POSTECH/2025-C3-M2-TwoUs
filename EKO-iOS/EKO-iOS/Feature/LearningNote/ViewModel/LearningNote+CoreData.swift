//
//  LearningNote+CoreData.swift
//  EKO-iOS
//
//  Created by 신민규 on 6/9/25.
//

// 기능: LearningNote ↔️ CachedLearningNote 변환 지원 (CoreData 저장 & 불러오기용)

import CoreData

// MARK: - LearningNote → CachedLearningNote 저장
extension LearningNote {
    func toCachedLearningNote(context: NSManagedObjectContext) -> CachedLearningNote {
        let cachedNote = CachedLearningNote(context: context)
        cachedNote.sessionId = sessionId
        cachedNote.receiverId = receiverId
        cachedNote.senderId = senderId
        cachedNote.status = status
        cachedNote.feedbackS3Key = feedbackS3Key
        cachedNote.createdAt = Int64(createdAt) // Int → Int64
        cachedNote.isFavorite = isFavorite
        cachedNote.s3Key = s3Key
        cachedNote.title = title
        cachedNote.voice1 = voice1
        cachedNote.voice2 = voice2
        return cachedNote
    }
}

// MARK: - CachedLearningNote → LearningNote 변환
extension CachedLearningNote {
    func toLearningNote() -> LearningNote {
        return LearningNote(
            sessionId: sessionId,
            receiverId: receiverId,
            senderId: senderId,
            status: status,
            feedbackS3Key: feedbackS3Key,
            createdAt: Int(createdAt), // Int64 → Int
            isFavorite: isFavorite,
            s3Key: s3Key,
            title: title,
            voice1: voice1,
            voice2: voice2
        )
    }
}
