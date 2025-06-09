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
    
    func fetchPresignedURL(for s3Key: String) async -> URL? {
        do {
            let result = try await NetworkService.shared.s3Service.fetchS3DownloadURL(s3Key: s3Key)
            return URL(string: result.url)
        } catch {
            print("❌ S3 URL 요청 실패: \(error)")
            return nil
        }
    }
    
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
                    voice1: note.s3Key,
                    voice2: note.feedbackS3Key
                )
            }
        } catch {
            print("노트 가져오기 실패:", error.localizedDescription)
        }
    }
    
    func patchFeedbackNoteFavorite(isFavorite:Bool, sessionId: String) async {
        
        let model = PatchNoteFavoriteRequestDTO(sessionId: sessionId, isFavorite: isFavorite)
        
        do {
            let result = try await NetworkService.shared.noteService.patchFeedbackNoteFavorite(model: model)
            print("\(result)")
        } catch {
            print("\(error)")
        }
        
    }
    
    func patchFeedbackNoteTitle(title: String, sessionId: String) async {
        
        let model = PatchNoteTitleRequestDTO(sessionId: sessionId, title: title)
        
        do {
            let result = try await NetworkService.shared.noteService.patchFeedbackNoteTitle(model: model)
            print("\(result)")
        } catch {
            print("\(error)")
        }
    }
    
    func deleteFeedbackNoteRequest(sessionId: String) async {
        
        let model = DeleteFeedbackNoteRequestDTO(sessionId: sessionId)
        
        do {
            let result = try await NetworkService.shared.noteService.deleteFeedbackNote(model: model)
            print("\(result)")
        } catch {
            print("\(error)")
        }
    }
}
