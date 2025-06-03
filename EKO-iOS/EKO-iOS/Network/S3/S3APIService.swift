//
//  UserAPIService.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation
import Moya

protocol S3APIServiceProtocol {
    func fetchS3DownloadURL(s3Key: String) async throws -> FetchS3DownloadURLResposeDTO
}

final class S3APIService: BaseAPIService<S3TargetType>,
  S3APIServiceProtocol {
    
    private let provider = MoyaProvider<S3TargetType>(plugins: [MoyaLoggerPlugin()])
    
    func fetchS3DownloadURL(s3Key: String) async throws -> FetchS3DownloadURLResposeDTO {
        let response = try await provider.request(.fetchS3DownloadURL(s3Key: s3Key))
        let result: NetworkResult<FetchS3DownloadURLResposeDTO> = fetchNetworkResult(
            statusCode: response.statusCode,
            data: response.data)
        switch result {
        case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return data
        default:
            throw NetworkResult<Error>.networkFail
        }
    }
}
