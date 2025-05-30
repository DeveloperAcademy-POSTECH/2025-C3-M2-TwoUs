//
//  SessionTargetType.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation
import Moya

enum SessionTargetType {
    case fetchSendQuestion(senderUserId: String)
    case postQuestionStarted
}

extension SessionTargetType: BaseTargetType {
    var headerType: [String: String]? { return ["Content-Type": "application/json"] }
    var utilPath: UtilPath { return .session }
    var pathParameter: String? { return .none }
    
    var queryParameter: [String: Any]? {
        switch self {
        case .fetchSendQuestion(let senderUserId):
            return ["senderUserId": senderUserId]
        default:
            return .none
        }
    }
    
    var requestBodyParameter: Codable? {
        switch self {
        case .fetchSendQuestion: return .none
        default: return .none
        }
    }
    
    var path: String {
        switch self {
        case .fetchSendQuestion: return utilPath.rawValue
        case .postQuestionStarted: return utilPath.rawValue + "/start"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchSendQuestion: return .get
        case .postQuestionStarted: return .post
        }
    }
}
