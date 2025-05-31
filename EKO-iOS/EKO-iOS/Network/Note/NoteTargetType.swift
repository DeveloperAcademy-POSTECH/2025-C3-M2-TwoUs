//
//  NoteTargetType.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation
import Moya

enum NoteTargetType {
    case fetchFeedbackNotes(senderId: String)
    case patchFeedbackNoteFavorite(model: PatchNoteFavoriteRequestDTO)
    case patchFeedbackNoteTitle(model: PatchNoteTitleRequestDTO)
}

extension NoteTargetType: BaseTargetType {
    var utilPath: UtilPath { return .note }
    var pathParameter: String? { return .none }
    
    var headerType: [String: String?] {
        switch self {
        case .fetchFeedbackNotes:
            return ["Content-Type": "application/json"]
        case .patchFeedbackNoteFavorite:
            return ["Content-Type": "application/json"]
        case .patchFeedbackNoteTitle:
            return ["Content-Type": "application/json"]
        }
  
    }
    
    var queryParameter: [String: Any]? {
        switch self {
        case .fetchFeedbackNotes(let senderId):
            return ["senderId": senderId]
        default: return .none
        }
    }
    
    var requestBodyParameter: (any Codable)? {
        switch self {
        case .fetchFeedbackNotes: return .none
        default: return .none
        }
    }
    
    var path: String {
        switch self {
        case .fetchFeedbackNotes: return utilPath.rawValue
        case .patchFeedbackNoteFavorite: return utilPath.rawValue + "/favorite"
        case .patchFeedbackNoteTitle: return utilPath.rawValue + "/title"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchFeedbackNotes: return .get
        case .patchFeedbackNoteFavorite: return .patch
        case .patchFeedbackNoteTitle: return .patch
        }
    }
    
    var task: Task {
        switch self {
        case let .fetchFeedbackNotes(senderId):
            return .requestParameters(parameters: ["senderId": senderId],
                                      encoding: URLEncoding.default)
        case let .patchFeedbackNoteFavorite(model):
            return .requestJSONEncodable(model)
        case let .patchFeedbackNoteTitle(model):
            return .requestJSONEncodable(model)
        }
    }
}
