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
    
    //let feedbackService: FeedbackAPIServiceProtocol = SessionAPIService()
    //let noteService: SessionAPIServiceProtocol = SessionAPIService()
    let sessionService: SessionAPIServiceProtocol = SessionAPIService()
    //let userService: SessionAPIServiceProtocol = SessionAPIService()
}
