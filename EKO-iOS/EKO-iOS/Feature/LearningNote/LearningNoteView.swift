//
//  LearningNoteView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

enum NoteFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case favorite = "즐겨찾기"
    case feedback = "Feedback"
    case good = "Good"
    
    var id: String { self.rawValue }
}

struct LearningNoteView: View {
    @State private var filter: NoteFilter = .all
    @State private var notes: [LearningNote] = LearningNote.dummyData
    @State private var editingNoteId: UUID? = nil
    @State private var newTitle: String = ""
    
    // MARK: - 필터링된 노트 리스트 반환 (선택된 필터에 따라 변경)
    var filteredNotes: [LearningNote] {
        switch filter {
        case .all: return notes
        case .favorite: return notes.filter { $0.isFavorite }
        case .feedback: return notes.filter { $0.status == "Bad" }
        case .good: return notes.filter { $0.status == "Good" }
        }
    }
    
    // MARK: - 노트 삭제 함수
    private func deleteNote(_ note: LearningNote) {
        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: idx)
        }
    }
    
    // MARK: - 노트 즐겨찾기 함수
    private func toggleFavorite(_ note: LearningNote) {
        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
            notes[idx].isFavorite.toggle()
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 🔵🔴 파랑~빨강 그라데이션 배경 (위→아래)
                LinearGradient(
                    colors: [Color.blue, Color.red],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                VStack {
                    // MARK: - 상단 필터 Menu (토글식 드롭다운 메뉴)
                    HStack {
                        Menu {
                            // 필터 메뉴 선택지 생성
                            ForEach(NoteFilter.allCases) { option in
                                Button(option.rawValue) {
                                    filter = option
                                }
                            }
                        } label: {
                            // 현재 필터 상태를 보여주는 Label
                            Label(filter.rawValue, systemImage: "line.3.horizontal.decrease.circle")
                                .font(.headline)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding([.top, .horizontal])
                    
                    // MARK: - 필터 적용된 노트 리스트
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredNotes, id: \.id) { note in
                                LearningNoteSubView(
                                    note: note,
                                    isEditing: editingNoteId == note.id,
                                    newTitle: newTitle,
                                    onStartEditing: {
                                        // 제목 수정 시작
                                        editingNoteId = note.id
                                        newTitle = note.title
                                    },
                                    onCommitEditing: { updatedTitle in
                                        // 제목 수정 완료
                                        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
                                            notes[idx].title = updatedTitle
                                        }
                                        editingNoteId = nil
                                    },
                                    onChangeTitle: { changedTitle in
                                        // 제목 텍스트 필드 실시간 값 반영
                                        newTitle = changedTitle
                                    },
                                    onToggleFavorite: {
                                        // 즐겨찾기 토글
                                        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
                                            notes[idx].isFavorite.toggle()
                                        }
                                    }
                                )
                                .padding()
                                .background(Color(.white))
                                .cornerRadius(22) //라운드값
                                .contextMenu {
                                    Button {
                                        toggleFavorite(note)
                                    } label: {
                                        if note.isFavorite {
                                            Label("즐겨찾기 해제", systemImage: "star.slash")
                                        } else {
                                            Label("즐겨찾기 등록", systemImage: "star")
                                        }
                                    }
                                    Button(role: .destructive) {
                                        deleteNote(note)
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("학습 노트")
            }
        }
    }
}

#Preview {
    LearningNoteView()
}
