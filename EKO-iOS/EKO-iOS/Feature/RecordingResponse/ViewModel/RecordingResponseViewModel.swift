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

    // ✅ 요청 목록 불러오기
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

    // ✅ 피드백 전송 (Good/Bad)
    func sendFeedback(status: String, fileURL: URL?) async {
        guard let sessionId = feedbackSessionId else {
            print("❌ sessionId 없음")
            return
        }

        guard let receiverId = selectedRequestUserId else {
            print("❌ 선택된 친구 없음")
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
            print("✅ 피드백 전송 성공: \(result)")
            await fetchMyRequestList()
        } catch {
            print("❌ 피드백 전송 실패: \(error)")
        }
    }

    // ✅ S3 키 가져오기
    func fetchFeedbackS3Key() async -> String? {
        do {
            let result = try await NetworkService.shared.feedbackService.fetchSendFeedback(receiverUserId: "userB456")
            if let session = result.sessions.first {
                self.feedbackS3Key = session.s3Key
                self.feedbackSessionId = session.sessionId
                return session.s3Key
            } else {
                print("❌ 세션 없음")
                return nil
            }
        } catch {
            print("❌ S3 키 가져오기 실패: \(error)")
            return nil
        }
    }

    // ✅ S3 URL 다운로드
    func downloadAudio() async {
        guard let s3Key = feedbackS3Key else {
            print("❌ s3Key 없음")
            return
        }

        do {
            let result = try await NetworkService.shared.s3Service.fetchS3DownloadURL(s3Key: s3Key)
            print("✅ S3 URL 획득: \(result.url)")

            if let url = URL(string: result.url) {
                self.playbackURL = url
            } else {
                print("❌ URL 파싱 실패")
            }
        } catch {
            print("❌ S3 다운로드 실패: \(error)")
        }
    }

    // ✅ 오디오 재생
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
