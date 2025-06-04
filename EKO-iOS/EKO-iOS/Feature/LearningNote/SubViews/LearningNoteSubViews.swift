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

    // 내부 편집 상태
    @State private var isEditing = false
    @State private var editedTitle: String = ""

    @State private var audioPlayer: AVAudioPlayer?

    // 수정 시작 시 note의 title로 초기화
    private func startEditing() {
        editedTitle = note.title
        isEditing = true
    }

    // MARK: - 음성 파일 재생 함수
    func playVoice(fileName: String) {
        let components = fileName.split(separator: ".")
        guard components.count == 2 else { return }
        if let url = Bundle.main.url(forResource: String(components[0]), withExtension: String(components[1])) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("음성파일 재생 오류:", error.localizedDescription)
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
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    Button(action: {
                    }) {
                        Image(systemName: note.isFavorite ? "star.fill" : "")
                            .foregroundStyle(note.isFavorite ? .yellow : .gray)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
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
                        .font(.system(size: 16))
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
            // voice1 버튼
            Button(action: {
                // playVoice(fileName: note.voice1)
            }) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.mainOrange)
            }
            .buttonStyle(.plain)
            
            if note.status == "Good" {
                Button(action: {
                    // playVoice(fileName: note.voice2)
                }) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.mainBlue)
                }
                .padding(.leading, 14)
            } else {
                // voice2 버튼
                Button(action: {
                    // playVoice(fileName: note.voice2)
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.mainBlue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
}
