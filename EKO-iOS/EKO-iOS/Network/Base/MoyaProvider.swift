//
//  MoyaProvider.swift
//  EKO-iOS
//
//  Created by mini on 5/29/25.
//

import Foundation
import Moya

extension MoyaProvider {
    func request(_ target: Target) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):    // 성공
                    continuation.resume(returning: response)
                case .failure(let error):       // 실패
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
