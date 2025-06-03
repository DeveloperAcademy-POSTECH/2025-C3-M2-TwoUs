//
//  LearningNoteSubViews.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI
import AVFoundation

struct LearningNoteSubView: View {
    // MARK: - Properties
    let note: LearningNote
    let isEditing: Bool
    let newTitle: String
    let onStartEditing: () -> Void
    let onCommitEditing: (String) -> Void
    let onChangeTitle: (String) -> Void
    let onToggleFavorite: () -> Void

    @State private var audioPlayer: AVAudioPlayer?

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
                        Image(systemName: note.isFavorite ? "star.fill" : "star")
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
                            text: Binding<String>(
                                get: { newTitle },
                                set: { value in onChangeTitle(value) }
                            ),
                            onCommit: {
                                onCommitEditing(newTitle)
                            }
                        )
                        .font(.system(size: 16))
                        Button("완료") {
                            onCommitEditing(newTitle)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text(note.title)
                            .font(.headline)
                        Button(action: {
                            onStartEditing()
                        }) {
                            Image(systemName: "pencil")
                                .foregroundStyle(.blue)
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
                        .font(.system(size: 50))
                        .foregroundStyle(.mainBlue)
                }
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
