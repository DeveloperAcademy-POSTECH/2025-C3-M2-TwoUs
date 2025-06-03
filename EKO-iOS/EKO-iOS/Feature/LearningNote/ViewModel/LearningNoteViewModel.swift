//
//  LearningNoteViewModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation

@MainActor
final class LearningNoteViewModel: ObservableObject {
    @Published var notes: [LearningNote] = []
    
    func fetchLearningNotes() async {
        do {
            let result = try await NetworkService.shared.noteService.fetchFeedbackNotes(senderId: "userA123")
            
            self.notes = result.notes.map { note in
                LearningNote(
                    sessionId: note.sessionId,
                    receiverId: note.receiverId,
                    senderId: note.senderId,
                    status: note.status,
                    feedbackS3Key: note.feedbackS3Key,
                    createdAt: note.createdAt,
                    isFavorite: note.isFavorite,
                    s3Key: note.s3Key,
                    title: note.title,
                    voice1: nil,
                    voice2: nil
                )
            }
        } catch {
            print("노트 가져오기 실패:", error.localizedDescription)
        }
    }
}
