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
    @State private var editingNoteId: UUID?
    @State private var newTitle: String = ""

    var filteredNotes: [LearningNote] {
        switch filter {
        case .all: return notes
        case .favorite: return notes.filter { $0.isFavorite }
        case .feedback: return notes.filter { $0.feedbackType == .feedback }
        case .good: return notes.filter { $0.feedbackType == .good }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Menu로 토글되는 필터 버튼
                HStack {
                    Menu {
                        ForEach(NoteFilter.allCases) { option in
                            Button(option.rawValue) {
                                filter = option
                            }
                        }
                    } label: {
                        Label(filter.rawValue, systemImage: "line.3.horizontal.decrease.circle")
                            .font(.headline)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding([.top, .horizontal])

                // 필터 적용된 리스트
                List {
                    ForEach(filteredNotes, id: \.id) { note in
                        LearningNoteSubView(
                            note: note,
                            isEditing: editingNoteId == note.id,
                            newTitle: newTitle,
                            onStartEditing: {
                                editingNoteId = note.id
                                newTitle = note.title
                            },
                            onCommitEditing: { updatedTitle in
                                if let idx = notes.firstIndex(where: { $0.id == note.id }) {
                                    notes[idx].title = updatedTitle
                                }
                                editingNoteId = nil
                            },
                            onChangeTitle: { changedTitle in
                                newTitle = changedTitle
                            },
                            onToggleFavorite: {
                                if let idx = notes.firstIndex(where: { $0.id == note.id }) {
                                    notes[idx].isFavorite.toggle()
                                }
                            }
                        )
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("학습 노트")
        }
    }
}

#Preview {
    LearningNoteView()
}
