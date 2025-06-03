//
//  RecordingRequestViewModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation

@MainActor
final class RecordingRequestViewModel: ObservableObject {
    func sendQuestion(from url: URL) async {
        do {
            let model = PostStartQuestionRequestDTO(
                senderUserId: "usdl",
                receiverUserId: "kon",
                audioFileURL: url
            )
            
            let result = try await NetworkService.shared.sessionService.postStartQuestion(model: model)
            print("✅ postStartFeedback result: \(result)")
        } catch {
            print("❌ postStartFeedback error: \(error)")
        }
    }
}


