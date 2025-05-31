//
//  UserTargetType.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation
import Moya

enum S3TargetType{
    case fetchS3DownloadURL(s3Key: String)
}

extension S3TargetType: BaseTargetType {
    var utilPath: UtilPath { return .s3 }
    var pathParameter: String? { return .none }
    
    var headerType: [String: String?]{
        switch self {
        case .fetchS3DownloadURL:
            return ["Content-Type": "application/json"]
        }
    }
    
    var queryParameter: [String : Any]? {
        switch self {
        case .fetchS3DownloadURL(let s3Key):
            return ["s3Key": s3Key]
        }
    }
    
    var requestBodyParameter: Codable? {
        switch self {
        case .fetchS3DownloadURL: return .none
        }
    }
    
    var path: String {
        switch self {
        case .fetchS3DownloadURL: return utilPath.rawValue + "presign"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchS3DownloadURL: return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .fetchS3DownloadURL(s3Key):
            return .requestParameters(parameters: ["s3Key": s3Key],
                                      encoding: JSONEncoding.default)
        }
    }
}
