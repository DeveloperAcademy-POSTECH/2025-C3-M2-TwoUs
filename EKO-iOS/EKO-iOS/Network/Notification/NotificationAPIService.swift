//
//  NotificationAPIService.swift
//  EKO-iOS
//
//  Created by mini on 5/30/25.
//

import Foundation
import Moya

protocol NotificationAPIServiceProtocol {
    func postDeviceToken(model: PostDeviceTokenRequestDTO) async throws -> [PostDeviceTokenResponseDTO]
}

final class NotificationAPIService: BaseAPIService<SessionTargetType>, NotificationAPIServiceProtocol {
    
    private let provider = MoyaProvider<NotificationTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func postDeviceToken(model: PostDeviceTokenRequestDTO) async throws -> [PostDeviceTokenResponseDTO] {
        let response = try await provider.request(.postDeviceToken(model: model))
        
        let result: NetworkResult<PostDeviceTokenResponseDTO> = fetchNetworkResult(
            statusCode: response.statusCode,
            data: response.data
        )
        
        switch result {
        case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return [data]
        default:
            throw NetworkResult<Error>.networkFail
        }
    }
}
