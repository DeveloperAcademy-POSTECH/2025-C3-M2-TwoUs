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
    
    // 피드백 전송
    func sendFeedback(status: String, fileURL: URL?) async {
        let model = PostStartFeedbackRequsetDTO(
            senderUserId: "kon",
            receiverUserId: "shina",
            sessionId: "shina#kon",
            status: status,
            feedbackFileURL: status == "Bad" ? fileURL : nil
        )
        
        do {
            let result = try await NetworkService.shared.feedbackService.postStartFeedback(model: model)
            print("Feedback 전송 성공: \(result)")
        } catch {
            print("Feedback 전송 실패: \(error)")
        }
    }
    
    // 들어온 피드백 조회 + 다운로드 URL 요청
    func fetchAudioPlaybackURL() async {
        do {
            let feedbacks = try await NetworkService.shared.feedbackService.fetchSendFeedback(receiverUserId: "kon")
            
            guard let firstDTO = feedbacks.first,
                  let s3Key = firstDTO.sessions.first?.s3Key else {
                print("❌ 피드백 세션에서 s3Key를 찾을 수 없음")
                return
            }
            
            let s3Responses = try await NetworkService.shared.s3Service.fetchS3DownloadURL(s3Key: s3Key)
            
            guard let urlString = s3Responses.first?.url,
                  let url = URL(string: urlString) else {
                print("❌ S3 다운로드 URL 파싱 실패")
                return
            }
            
            self.playbackURL = url
            print("✅ 다운로드 URL 준비 완료: \(url.absoluteString)")
            
        } catch {
            print("❌ 다운로드 URL 생성 실패: \(error)")
        }
    }
}
