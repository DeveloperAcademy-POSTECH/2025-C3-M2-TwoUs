//
//  NetworkService.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation

final class NetworkService {
    
    static let shared = NetworkService()

    private init() {}
    
    //let feedbackService: FeedbackAPIServiceProtocol = FeedbackAPIService()
    //let noteService: SessionAPIServiceProtocol = NoteAPIService()
    //let notificationService: SessionAPIServiceProtocol = NotificationAPIService()
    let sessionService: SessionAPIServiceProtocol = SessionAPIService()
    //let userService: SessionAPIServiceProtocol = UserAPIService()
}
