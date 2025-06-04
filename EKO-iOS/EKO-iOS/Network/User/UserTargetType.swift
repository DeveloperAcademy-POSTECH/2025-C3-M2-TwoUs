//
//  UserTargetType.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation
import Moya

enum UserTargetType {
    case fetchMyProfile(userId: String)
    case postRegister(model: PostRegisterRequestDTO)
    case fetchFriendsProfile(userAddCode: String)
    case postNewFriends(model: PostNewFriendsRequestDTO)
    case fetchMyFriendsList(userId: String)
}

extension UserTargetType: BaseTargetType {
    var utilPath: UtilPath { return .session }
    var pathParameter: String? { return .none }
    
    var headerType: [String: String?]{
        switch self {
        case .fetchMyProfile:
            return ["Content-Type" : "application/json"]
        case .postRegister:
            return ["Content-Type" : "application/json"]
        case .fetchFriendsProfile:
            return ["Content-Type" : "application/json"]
        case .postNewFriends:
            return ["Content-Type" : "multipart/form-data"]
        case .fetchMyFriendsList:
            return ["Content-Type" : "application/json"]
        }
    }
    
    var queryParameter: [String : Any]? {
        switch self {
        case .fetchMyProfile(userId: let userId):
            return ["userId": userId]
        case .fetchFriendsProfile(userAddCode: let userAddCode):
            return ["userAddCode": userAddCode]
        case .fetchMyFriendsList(userId: let userId):
            return ["userId": userId]
        default:
            return .none
        }
    }
    
    var requestBodyParameter: Codable? {
        switch self {
        case .fetchMyProfile: return .none
        case .fetchFriendsProfile: return .none
        case .fetchMyFriendsList: return .none
        default: return .none
        }
    }
    
    var path: String {
        switch self {
        case .fetchMyProfile: return utilPath.rawValue + "/myprofile"
        case .postRegister: return utilPath.rawValue + "/register"
        case .fetchFriendsProfile: return utilPath.rawValue + "/friends"
        case .postNewFriends: return utilPath.rawValue + "/friends/list"
        case .fetchMyFriendsList: return utilPath.rawValue + "/friends/list"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchMyProfile: return .get
        case .postRegister: return .post
        case .fetchFriendsProfile: return .get
        case .postNewFriends: return .post
        case .fetchMyFriendsList: return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .fetchMyProfile(userId):
            return .requestParameters(parameters: ["userId":userId], encoding: URLEncoding.default)
        case let .postRegister(model):
            return .requestJSONEncodable(model)
        case let .fetchFriendsProfile(userAddCode):
            return .requestParameters(parameters: ["userAddCode":userAddCode], encoding: URLEncoding.default)
        case let .postNewFriends(model):
            return .requestJSONEncodable(model)
        case let .fetchMyFriendsList(userId):
            return .requestParameters(parameters: ["userId":userId], encoding: URLEncoding.default)
        }
    }
}
