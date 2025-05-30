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
    case postStartQuestion(model: PostStartQuestionRequestDTO)
}

extension SessionTargetType: BaseTargetType {
    var utilPath: UtilPath { return .session }
    var pathParameter: String? { return .none }
    
    var headerType: [String: String]? {
        switch self {
        case .postStartQuestion:
            return ["Content-Type": "multipart/form-data"]
        case .fetchSendQuestion:
            return ["Content-Type": "application/json"]
        }
    }
    
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
        case .postStartQuestion: return utilPath.rawValue + "/start"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchSendQuestion: return .get
        case .postStartQuestion: return .post
        }
    }
    
    var task: Task {
        switch self {
        case let .fetchSendQuestion(senderUserId):
            return .requestParameters(parameters: ["senderUserId": senderUserId],
                                      encoding: URLEncoding.default)

        case let .postStartQuestion(model):
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
                    provider: .file(model.audioFileURL),
                    name: "audioFile",
                    fileName: model.audioFileURL.lastPathComponent,
                    mimeType: "audio/m4a"
                )
            )

            return .uploadMultipart(multipart)
        }
    }
}
