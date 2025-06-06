//
//  LearningNoteView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

enum NoteFilter: String, CaseIterable, Identifiable {
    case all = "전체노트"
    case good = "Good"
    case feedback = "Feedback"
    case favorite = "즐겨찾기"
    
    var id: String { self.rawValue }
}

struct LearningNoteView: View {
    @State private var filter: NoteFilter = .all
    @State private var editingNoteId: String? = nil
    @State private var newTitle: String = ""
    @StateObject private var viewModel = LearningNoteViewModel()

    // MARK: - 필터링된 노트 리스트 반환
    var filteredNotes: [LearningNote] {
        switch filter {
        case .all: return viewModel.notes
        case .feedback: return viewModel.notes.filter { $0.status == "Bad" }
        case .good: return viewModel.notes.filter { $0.status == "Good" }
        case .favorite: return viewModel.notes.filter { $0.isFavorite }
        }
    }
    
    // MARK: - 노트 삭제
    private func deleteNote(_ note: LearningNote) {
        viewModel.notes.removeAll { $0.id == note.id }
    }

    // MARK: - 즐겨찾기 토글
    private func toggleFavorite(_ note: LearningNote) {
        if let idx = viewModel.notes.firstIndex(where: { $0.id == note.id }) {
                viewModel.notes[idx].isFavorite.toggle()
                let newFavorite = viewModel.notes[idx].isFavorite
                let sessionId = viewModel.notes[idx].sessionId

                Task {
                    await viewModel.patchFeedbackNoteFavorite(isFavorite: newFavorite, sessionId: sessionId)
                }
            }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                EKOToggleIndicator(type: .upDirection)
                LinearGradient(
                    colors: [Color.supBlue4, Color.supOrange2],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    // MARK: - 필터 메뉴 및 불러오기 버튼
                    HStack {
                        Menu {
                            ForEach(NoteFilter.allCases) { option in
                                Button(option.rawValue) {
                                    filter = option
                                }
                            }
                        } label: {
                            Label(filter.rawValue, systemImage: "")
                                .font(.title01)
                                .foregroundStyle(.black)
                            Image(systemName: "chevron.down")
                                .font(.title01)
                                .foregroundStyle(.black)
                        }
                        
                            
                        Spacer()
                        Button("노트 불러오기") {
                            Task {
                                await viewModel.fetchLearningNotes()
                            }
                        }
                    }
                    .padding([.top, .horizontal])
                    
                    // MARK: - 노트 리스트
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredNotes, id: \.id) { note in
                                LearningNoteSubView(note: note, viewModel: viewModel)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .cornerRadius(15)
                                .contextMenu {
                                    Button {
                                        Task {
                                            await viewModel.patchFeedbackNoteFavorite(isFavorite: note.isFavorite ? false : true, sessionId: note.sessionId)
                                            await viewModel.fetchLearningNotes()
                                        }
                                    } label: {
                                        if note.isFavorite {
                                            Label("즐겨찾기 해제", systemImage: StringLiterals.starSlash)
                                        } else {
                                            Label("즐겨찾기 등록", systemImage: StringLiterals.star)
                                        }
                                    }
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.deleteFeedbackNoteRequest(sessionId: note.sessionId)
                                            await viewModel.fetchLearningNotes()
                                        }
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("")
                
            }
        }
    }
}

#Preview {
    LearningNoteView()
}
