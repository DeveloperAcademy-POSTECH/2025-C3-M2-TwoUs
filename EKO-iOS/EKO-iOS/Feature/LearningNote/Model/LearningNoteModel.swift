//
//  LearningNoteModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation

enum FeedbackType: String, Codable {
    case none
    case good
    case feedback
}

struct LearningNote: Identifiable {
    let id: UUID
    let userName: String
    let date: String
    var title: String
    let profileIcon: String
    let voice1: String
    let voice2: String?
    var isFavorite: Bool       // 즐겨찾기 여부 추가
    var feedbackType: FeedbackType
}

// 예시 더미데이터
extension LearningNote {
    static let dummyData: [LearningNote] = [
        LearningNote(
            id: UUID(),
            userName: "JUNIA",
            date: "05.24",
            title: "05.24의 보이스",
            profileIcon: "person.fill",
            voice1: "voice_memo_20250528_1.m4a",
            voice2: "voice_memo_20250528_2.m4a",
            isFavorite: false,
            feedbackType: .feedback
        ),
        LearningNote(
            id: UUID(),
            userName: "KON",
            date: "05.25",
            title: "05.25의 보이스",
            profileIcon: "person.fill",
            voice1: "voice_memo_20250528_3.m4a",
            voice2: "voice_memo_20250528_4.m4a",
            isFavorite: false,
            feedbackType: .good
        ),
        LearningNote(
            id: UUID(),
            userName: "GLOWNY",
            date: "05.25",
            title: "05.25의 보이스",
            profileIcon: "person.fill",
            voice1: "voice_memo_20250528_5.m4a",
            voice2: nil,
            isFavorite: false,
            feedbackType: .none
        ),
        LearningNote(
            id: UUID(),
            userName: "ELIAN",
            date: "05.25",
            title: "05.25의 보이스",
            profileIcon: "person.fill",
            voice1: "voice_memo_20250528_7.m4a",
            voice2: "voice_memo_20250528_8.m4a",
            isFavorite: false,
            feedbackType: .feedback
        ),
        LearningNote(
            id: UUID(),
            userName: "MINI",
            date: "05.25",
            title: "05.25의 보이스",
            profileIcon: "person.fill",
            voice1: "voice_memo_20250528_9.m4a",
            voice2: "voice_memo_20250528_10.m4a",
            isFavorite: false,
            feedbackType: .good
        )
        // 필요에 따라 더 추가
    ]
}
