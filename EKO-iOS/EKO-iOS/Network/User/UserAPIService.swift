//
//  UserAPIService.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation
import Moya

protocol UserAPIServiceProtocol {
    func fetchMyprofile(userId: String) async throws -> FetchMyprofileResponseDTO
    func postRegister(model: PostRegisterRequestDTO) async throws -> PostRegisterResponseDTO
    func fetchFriendsProfile(userAddCode: String) async throws -> FetchFriendsProfileResponseDTO
    func postNewfriendsRequest(model: PostNewFriendsRequestDTO) async throws -> PostNewFriendsResponseDTO
    func fetchMyFriendsList(userId: String) async throws -> FetchMyFriendsListResponseDTO
}

final class UserAPIService: BaseAPIService<UserTargetType>, UserAPIServiceProtocol {
    
    private let provider = MoyaProvider<UserTargetType>(plugins: [NetworkLoggerPlugin()])
    
    func fetchMyprofile(userId: String) async throws -> FetchMyprofileResponseDTO {
        let response = try await provider.request(.fetchMyProfile(userId: userId))
        let result: NetworkResult<FetchMyprofileResponseDTO> = fetchNetworkResult(statusCode: response.statusCode, data: response.data)
        switch result {
        case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return data
        default :
            throw NetworkResult<Error>.networkFail
        }
    }
    
    func postRegister(model: PostRegisterRequestDTO) async throws -> PostRegisterResponseDTO {
        let response = try await provider.request(.postRegister(model: model))
        let result: NetworkResult<PostRegisterResponseDTO> = fetchNetworkResult(statusCode: response.statusCode, data: response.data)
        switch result {
        case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return data
        default:
            throw NetworkResult<Error>.networkFail
        }
    }
    
    func fetchFriendsProfile(userAddCode: String) async throws -> FetchFriendsProfileResponseDTO {
        let response = try await provider.request(.fetchFriendsProfile(userAddCode: userAddCode))
        let result: NetworkResult<FetchFriendsProfileResponseDTO> = fetchNetworkResult(statusCode: response.statusCode, data: response.data)
        switch result {
        case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return data
        default:
            throw NetworkResult<Error>.networkFail
        }
    }
    
    func postNewfriendsRequest(model: PostNewFriendsRequestDTO) async throws -> PostNewFriendsResponseDTO {
        let response = try await provider.request(.postNewFriends(model: model))
        let result: NetworkResult<PostNewFriendsResponseDTO> = fetchNetworkResult(statusCode: response.statusCode, data: response.data)
        switch result {
        case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return data
        default:
            throw NetworkResult<Error>.networkFail
        }
    }
    
    func fetchMyFriendsList(userId: String) async throws -> FetchMyFriendsListResponseDTO {
        let response = try await provider.request(.fetchMyFriendsList(userId: userId))
        let result: NetworkResult<FetchMyFriendsListResponseDTO> = fetchNetworkResult(statusCode: response.statusCode, data: response.data)
        switch result {
            case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return data
        default:
            throw NetworkResult<Error>.networkFail
        }
    }
}
