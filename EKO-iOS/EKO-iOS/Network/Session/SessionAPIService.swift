//
//  SessionAPIService.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation
import Moya

protocol SessionAPIServiceProtocol {
    func fetchSendQuestion(senderUserId: String) async throws -> [FetchSendQuestionResponseDTO]
    func postStartQuestion(model: PostStartQuestionRequestDTO) async throws -> [PostStartQuestionResponseDTO]
}

final class SessionAPIService: BaseAPIService<SessionTargetType>, SessionAPIServiceProtocol {
    
    private let provider = MoyaProvider<SessionTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func fetchSendQuestion(senderUserId: String) async throws -> [FetchSendQuestionResponseDTO] {
        let response = try await provider.request(.fetchSendQuestion(senderUserId: senderUserId))
        let result: NetworkResult<[FetchSendQuestionResponseDTO]> = fetchNetworkResult(
            statusCode: response.statusCode,
            data: response.data
        )
        switch result {
        case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return data
        default:
            throw NetworkResult<Error>.networkFail
        }
    }
    
    func postStartQuestion(model: PostStartQuestionRequestDTO) async throws -> [PostStartQuestionResponseDTO] {
        let response = try await provider.request(.postStartQuestion(model: model))
        let result: NetworkResult<[PostStartQuestionResponseDTO]> = fetchNetworkResult(
            statusCode: response.statusCode,
            data: response.data
        )
        switch result {
        case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return data
        default:
            throw NetworkResult<Error>.networkFail
        }
    }
}
