//
//  FeedbackAPIService.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation
import Moya

protocol FeedbackAPIServiceProtocol {
    func fetchSendFeedback(receiverUserId: String) async throws ->
        [FetchSendFeedbackResponseDTO]
    func postStartFeedback(model: PostStartFeedbackRequsetDTO) async throws -> [PostStartFeedbackResponseDTO]
}

final class FeedbackAPIService: BaseAPIService<FeedbackTargetType>, FeedbackAPIServiceProtocol {
    
    private let provider = MoyaProvider<FeedbackTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func fetchSendFeedback(receiverUserId: String) async throws -> [FetchSendFeedbackResponseDTO] {
        let response = try await provider.request(.fetchSendFeedback(receiverUserId: receiverUserId))
        let result: NetworkResult<[FetchSendFeedbackResponseDTO]> = fetchNetworkResult(
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
    
    func postStartFeedback(model: PostStartFeedbackRequsetDTO) async throws -> [PostStartFeedbackResponseDTO] {
        let response = try await provider.request(.postStartFeedback(model: model))
        let result: NetworkResult<[PostStartFeedbackResponseDTO]> = fetchNetworkResult(
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
