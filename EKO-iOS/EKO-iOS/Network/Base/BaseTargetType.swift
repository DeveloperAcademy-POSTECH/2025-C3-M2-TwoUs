//
//  BaseTargetType.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation
import Moya

enum UtilPath: String {
    case feedback = "feedback"
    case note = "notes"
    case notification = "notifications"
    case session = "sessions"
    case user = "users"
}

protocol BaseTargetType: TargetType {
    var utilPath: UtilPath { get }
    var pathParameter: String? { get }
    var queryParameter: [String: Any]? { get }
    var requestBodyParameter: Codable? { get }
}

extension BaseTargetType {
    var baseURL: URL {
        guard let baseURL = URL(string: Config.baseURL) else {
            fatalError("🍞⛔️ Base URL이 없어요! ⛔️🍞")
        }
        return baseURL
    }
        
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
