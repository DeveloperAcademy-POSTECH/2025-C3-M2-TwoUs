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
    
    @Published var friends: [EKORequestFriend] = []
    @Published var selectedRequestUserId: String?
    
    struct EKORequestFriend: Identifiable, Equatable {
        let id = UUID()
        let senderUserId: String
        let senderNickname: String
    }
    
    func fetchMyRequestList() async {
        do {
            let response = try await NetworkService.shared.feedbackService.fetchSendFeedback(receiverUserId: "userB456")
            let fetched = response.sessions.map {
                EKORequestFriend(
                    senderUserId: $0.senderUserId,
                    senderNickname: $0.senderNickname
                )
            }
            self.friends = fetched
            self.selectedRequestUserId = fetched.first?.senderUserId
        } catch {
            print("요청 목록 불러오기 실패: \(error.localizedDescription)")
        }
    }

    func sendFeedback(status: String, fileURL: URL?) async {
        guard let sessionId = feedbackSessionId else {
            return
        }
        
        guard let receiverId = selectedRequestUserId else {
            print("선택된 친구가 없습니다.")
            return
        }

        let model = PostStartFeedbackRequsetDTO(
            senderUserId: "userB456",
            receiverUserId: receiverId,
            sessionId: sessionId,
            status: status,
            feedbackFileURL: status == "Bad" ? fileURL : nil
        )

        do {
            let result = try await NetworkService.shared.feedbackService.postStartFeedback(model: model)
            print("\(result)")
            await fetchMyRequestList()
        } catch {
            print("\(error)")
        }
    }

    func fetchFeedbackS3Key() async -> String? {
        do {
            let result = try await NetworkService.shared.feedbackService.fetchSendFeedback(receiverUserId: "userB456")
            if let session = result.sessions.first {
                self.feedbackS3Key = session.s3Key
                self.feedbackSessionId = session.sessionId
                return session.s3Key
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

    func downloadAudio() async {
        guard let s3Key = feedbackS3Key else {
            return
        }
        
        do {
            let result = try await NetworkService.shared.s3Service.fetchS3DownloadURL(s3Key: s3Key)
            
            print(result)

            if let url = URL(string: result.url) {
                self.playbackURL = url
            } else {
                print("URL 파싱 실패")
            }
        } catch {
            print("S3 URL error: \(error)")
        }
    }
    
    func playFeedback(using player: AudioPlayer) async {
        guard let _ = await fetchFeedbackS3Key() else {
            print("❌ s3Key를 가져오지 못해 재생 중단")
            return
        }

        await downloadAudio()

        if let url = playbackURL {
            print("🎧 피드백 오디오 재생: \(url)")
            player.downloadAndPlayWithHaptics(from: url)
        } else {
            print("❌ 다운로드된 URL이 없어 재생 불가")
        }
    }
}
