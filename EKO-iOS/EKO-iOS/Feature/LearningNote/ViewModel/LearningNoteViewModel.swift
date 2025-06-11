//
//  LearningNoteViewModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation
import CoreData

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
            let result = try await NetworkService.shared.noteService.fetchFeedbackNotes(senderId: UserDefaults.standard.string(forKey: "userId") ?? "")
            
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
            saveLearningNotes(notes: self.notes)
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
    
    
    func saveLearningNotes(notes: [LearningNote]) {
        let context = CoreDataManager.shared.context
        
        for note in notes {
            // 기존에 동일한 sessionId 가 있는지 확인
            let fetchRequest: NSFetchRequest<CachedLearningNote> = CachedLearningNote.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "sessionId == %@", note.sessionId ?? "")
            
            do {
                let existingNotes = try context.fetch(fetchRequest)
                let cachedNote: CachedLearningNote
                
                if let existing = existingNotes.first {
                    // 기존 데이터 업데이트
                    cachedNote = existing
                } else {
                    // 새로 추가
                    cachedNote = CachedLearningNote(context: context)
                    cachedNote.sessionId = note.sessionId
                }
                
                // 공통 필드 업데이트
                cachedNote.receiverId = note.receiverId
                cachedNote.senderId = note.senderId
                cachedNote.status = note.status
                cachedNote.feedbackS3Key = note.feedbackS3Key
                cachedNote.createdAt = Int64(note.createdAt ?? 0)
                cachedNote.isFavorite = note.isFavorite
                cachedNote.s3Key = note.s3Key
                cachedNote.title = note.title
                cachedNote.voice1 = note.voice1
                cachedNote.voice2 = note.voice2
                
            } catch {
                print("❌ Failed to fetch CachedLearningNote for sessionId \(note.sessionId ?? ""): \(error)")
            }
        }
        
        CoreDataManager.shared.saveContext()
        print("✅ Learning notes saved to CoreData.")
    }
    
    func loadLearningNotes() {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<CachedLearningNote> = CachedLearningNote.fetchRequest()
        
        // ✅ 정렬 조건 추가 → createdAt 내림차순 (최신순 정렬)
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let cachedNotes = try context.fetch(fetchRequest)
            print("✅ CoreData에서 \(cachedNotes.count)개의 학습노트 불러옴.")
            
            self.notes = cachedNotes.map { cachedNote in
                LearningNote(
                    sessionId: cachedNote.sessionId,
                    receiverId: cachedNote.receiverId,
                    senderId: cachedNote.senderId,
                    status: cachedNote.status,
                    feedbackS3Key: cachedNote.feedbackS3Key,
                    createdAt: Int(cachedNote.createdAt),
                    isFavorite: cachedNote.isFavorite,
                    s3Key: cachedNote.s3Key,
                    title: cachedNote.title,
                    voice1: cachedNote.voice1,
                    voice2: cachedNote.voice2
                )
            }
        } catch {
            print("❌ CoreData에서 학습노트 불러오기 실패: \(error)")
        }
    }
}
