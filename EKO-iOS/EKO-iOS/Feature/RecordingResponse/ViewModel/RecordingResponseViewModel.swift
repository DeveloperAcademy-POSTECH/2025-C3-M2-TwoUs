//
//  RecordingResponseViewModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation

@MainActor
final class RecordingResponseViewModel: ObservableObject {
    @Published var playbackURL: URL?
    @Published var feedbackS3Key: String?
    @Published var feedbackSessionId: String?

    func sendFeedback(status: String, fileURL: URL?) async {
        guard let sessionId = feedbackSessionId else {
            print("❌ sessionId가 설정되지 않음")
            return
        }

        let model = PostStartFeedbackRequsetDTO(
            senderUserId: "kon",
            receiverUserId: "usdl",
            sessionId: sessionId,
            status: status,
            feedbackFileURL: status == "Bad" ? fileURL : nil
        )

        do {
            let result = try await NetworkService.shared.feedbackService.postStartFeedback(model: model)
            print("✅ Feedback 전송 성공: \(result)")
        } catch {
            print("❌ Feedback 전송 실패: \(error)")
        }
    }

    func fetchFeedbackS3Key() async -> String? {
        do {
            let result = try await NetworkService.shared.feedbackService.fetchSendFeedback(receiverUserId: "kon")
            if let session = result.sessions.first {
                self.feedbackS3Key = session.s3Key
                self.feedbackSessionId = session.sessionId
                print("✅ s3Key 추출 완료: \(session.s3Key)")
                print("✅ sessionId 추출 완료: \(session.sessionId)")
                return session.s3Key
            } else {
                print("❌ sessions에 데이터 없음")
                return nil
            }
        } catch {
            print("❌ Fetch Feedback error: \(error)")
            return nil
        }
    }

    func downloadAudio() async {
        guard let s3Key = feedbackS3Key else {
            print("❌ S3Key가 설정되지 않음")
            return
        }
        
        do {
            let result = try await NetworkService.shared.s3Service.fetchS3DownloadURL(s3Key: s3Key)
            
            print(result)

            if let url = URL(string: result.url) {
                self.playbackURL = url
                print("✅ 다운로드 URL 준비 완료: \(url.absoluteString)")
            } else {
                print("❌ URL 파싱 실패")
            }
        } catch {
            print("❌ Fetch S3 URL error: \(error)")
        }
    }
}
