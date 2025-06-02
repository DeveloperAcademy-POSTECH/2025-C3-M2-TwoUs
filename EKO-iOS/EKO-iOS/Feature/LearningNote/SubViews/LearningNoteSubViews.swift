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
                    Image(systemName: note.profileIcon)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    Text(note.receiverId)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                        .textFieldStyle(.roundedBorder)
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

                    // Spacer로 오른쪽 끝으로 voice 버튼 이동
                    Spacer()

                    // voice1 버튼
                    Button(action: {
                        playVoice(fileName: note.voice1)
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)

                    // voice2 버튼(없으면 placeholder)
                    if let voice2 = note.voice2, !voice2.isEmpty {
                        Button(action: {
                            playVoice(fileName: voice2)
                        }) {
                            Image(systemName: "play.circle")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        .frame(width: 32, height: 32)
                        .padding(.leading, 4)
                    } else {
                        Color.clear
                            .frame(width: 32, height: 32)
                            .padding(.leading, 4)
                    }
                }
            }
            // 별 버튼은 가장 오른쪽 끝에
            Spacer(minLength: 12)
            Button(action: {
            }) {
                Image(systemName: note.isFavorite ? "star.circle.fill" : "star.circle")
                    .foregroundStyle(note.isFavorite ? .yellow : .gray)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .padding(.top, -40)
        }
        .padding(.vertical, 8)
    }
}
