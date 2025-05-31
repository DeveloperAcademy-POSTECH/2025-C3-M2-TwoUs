//
//  FeedbackTargetType.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation
import Moya

enum FeedbackTargetType {
    case fetchSendFeedback(receiverUserId: String)
    case postStartFeedback(model: PostStartFeedbackRequsetDTO)
}

extension FeedbackTargetType: BaseTargetType {
    var utilPath: UtilPath { return .feedback }
    var pathParameter: String? { return .none }
    
    var headerType: [String: String]? {
        switch self {
        case .postStartFeedback:
            return ["Content-Type": "multipart/form-data"]
        case .fetchSendFeedback:
            return ["Content-Type": "application/json"]
        }
    }
    
    var queryParameter: [String: Any]? {
        switch self {
        case .fetchSendFeedback(let receiverUserId):
            return ["receiverUserId": receiverUserId]
        default:
            return .none
        }
    }
    
    var requestBodyParameter: Codable? {
        switch self {
        case .fetchSendFeedback: return .none
        default: return .none
        }
    }
    
    var path: String {
        switch self {
        case .fetchSendFeedback: return utilPath.rawValue
        case .postStartFeedback: return utilPath.rawValue + "/start"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchSendFeedback: return .get
        case .postStartFeedback: return .post
        }
    }
    
    var task: Task {
        switch self {
        case let .fetchSendFeedback(receiverUserId):
            return .requestParameters(parameters: ["receiverUserId": receiverUserId],
                                      encoding: URLEncoding.default)
        case let .postStartFeedback(model):
            var multipart: [MultipartFormData] = []
            
            multipart.append(
                MultipartFormData(
                    provider: .data(model.senderUserId.data(using: .utf8)!),
                    name: "senderUserId"
                )
            )

            multipart.append(
                MultipartFormData(
                    provider: .data(model.receiverUserId.data(using: .utf8)!),
                    name: "receiverUserId"
                )
            )
            
            multipart.append(
                MultipartFormData(
                    provider: .data(model.sessionId.data(using: .utf8)!),
                    name: "sessionId"
                )
            )
            
            multipart.append(
                MultipartFormData(
                    provider: .data(model.status.data(using: .utf8)!),
                    name: "status"
                )
            )
            
            if model.status == "Bad", let fileURL = model.feedbackFileURL {
                multipart.append(MultipartFormData(
                    provider: .file(fileURL),
                    name: "feedbackFile",
                    fileName: fileURL.lastPathComponent,
                    mimeType: "audio/m4a"
                ))
            }
            
            return .uploadMultipart(multipart)
        }
    }
}
