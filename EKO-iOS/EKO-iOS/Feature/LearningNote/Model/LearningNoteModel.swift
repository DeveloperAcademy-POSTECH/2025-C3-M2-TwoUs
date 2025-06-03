//
//  LearningNoteModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation

struct LearningNote: Identifiable {
    let id: UUID
    let receiverId: String
    let createAt: String
    var title: String
    let profileIcon: String
    let voice1: String
    let voice2: String?
    var isFavorite: Bool       // 즐겨찾기 여부 추가
    var status: String         //Good,Bad
}

// 예시 더미데이터
extension LearningNote {
    static let dummyData: [LearningNote] = [
        LearningNote(
            id: UUID(),
            receiverId: "JUNIA",
            createAt: "05.24",
            title: "05.24의 보이스",
            profileIcon: "person.fill",
            voice1: "voice_memo_20250528_1.m4a",
            voice2: "voice_memo_20250528_2.m4a",
            isFavorite: false,
            status: "Good"
        ),
        LearningNote(
            id: UUID(),
            receiverId: "KON",
            createAt: "05.25",
            title: "05.25의 보이스",
            profileIcon: "person.fill",
            voice1: "voice_memo_20250528_3.m4a",
            voice2: "voice_memo_20250528_4.m4a",
            isFavorite: false,
            status: "Good"
        ),
        LearningNote(
            id: UUID(),
            receiverId: "GLOWNY",
            createAt: "05.25",
            title: "05.25의 보이스",
            profileIcon: "person.fill",
            voice1: "voice_memo_20250528_5.m4a",
            voice2: nil,
            isFavorite: false,
            status: "Bad"
        ),
        LearningNote(
            id: UUID(),
            receiverId: "ELIAN",
            createAt: "05.25",
            title: "05.25의 보이스",
            profileIcon: "person.fill",
            voice1: "voice_memo_20250528_7.m4a",
            voice2: "voice_memo_20250528_8.m4a",
            isFavorite: false,
            status: "Bad"
        ),
        LearningNote(
            id: UUID(),
            receiverId: "MINI",
            createAt: "05.25",
            title: "05.25의 보이스",
            profileIcon: "person.fill",
            voice1: "voice_memo_20250528_9.m4a",
            voice2: "voice_memo_20250528_10.m4a",
            isFavorite: false,
            status: "Good"
        )
        // 필요에 따라 더 추가
    ]
}
