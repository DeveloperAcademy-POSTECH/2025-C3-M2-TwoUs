//
//  LearningNoteSubViews.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI
import AVFoundation

struct LearningNoteSubView: View {
    let note: LearningNote
    @ObservedObject var viewModel: LearningNoteViewModel
    @State private var audioPlayer = AudioPlayer()

    // 내부 편집 상태
    @State private var isEditing = false
    @State private var editedTitle: String = ""
    
    // Voice1 재생 상태 관리
    @State private var isPlayingVoice1 = false
    @State private var isPlayingVoice2 = false

    // 수정 시작 시 note의 title로 초기화
    private func startEditing() {
        editedTitle = note.title
        isEditing = true
    }

    // MARK: - 음성 파일 재생 함수
    private func playVoice(from s3Key: String) {
        Task {
            if let url = await viewModel.fetchPresignedURL(for: s3Key) {
                audioPlayer.downloadAndPlayWithHaptics(from: url)
            } else {
                print("❌ Presigned URL 가져오기 실패")
            }
        }
    }

    // MARK: - 뷰 본문
    var body: some View {
        HStack {
            // 왼쪽: 프로필, 이름
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(note.receiverId)
                        .font(.textRegular03)
                        .foregroundStyle(.secondary)
                    Button(action: {
                    }) {
                        Image(systemName: note.isFavorite ? "star.fill" : "")
                            .foregroundStyle(note.isFavorite ? .yellow : .gray)
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 4)
                }
                // 제목(수정) + Spacer() + voice 버튼 그룹 한 줄 배치
                HStack {
                    if isEditing {
                        TextField(
                            "제목을 입력하세요",
                            text: $editedTitle,
                            onCommit: {
                                Task {
                                    await viewModel.patchFeedbackNoteTitle(title: editedTitle, sessionId: note.sessionId)
                                    await viewModel.fetchLearningNotes()
                                    isEditing = false
                                }
                            }
                        )
                        .font(.textRegular03)
                        .textFieldStyle(.roundedBorder)
                    } else {
                        Text(note.title)
                            .font(.headline)
                        Button(action: startEditing) {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            Spacer()
            
            // MARK: - Voice1 버튼 (Play / Pause 토글)
            if isPlayingVoice1 {
                // Pause 버튼
                Button(action: {
                    audioPlayer.pause()
                    isPlayingVoice1 = false
                }) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 45))
                        .foregroundStyle(.mainOrange)
                }
                .buttonStyle(.plain)
            } else {
                // Play 버튼
                Button(action: {
                    if let voice1 = note.voice1 {
                        playVoice(from: voice1)
                        isPlayingVoice1 = true
                    }
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 45))
                        .foregroundStyle(.mainOrange)
                }
                .buttonStyle(.plain)
            }
            
            // MARK: - Voice2 or Good 상태 표시 (Play / Pause 토글)
            if note.status == "Good" {
                // 따봉 표시 고정
                Button(action: {
                }) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.mainBlue)
                        .padding(.trailing, 3)
                        .padding(.leading, 4)
                }
            } else {
                if isPlayingVoice2 {
                    // Pause 버튼
                    Button(action: {
                        audioPlayer.pause()
                        isPlayingVoice2 = false
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 45))
                            .foregroundStyle(.mainBlue)
                    }
                    .buttonStyle(.plain)
                } else {
                    // Play 버튼
                    Button(action: {
                        if let voice2 = note.voice2 {
                            playVoice(from: voice2)
                            isPlayingVoice2 = true
                        }
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 45))
                            .foregroundStyle(.mainBlue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
