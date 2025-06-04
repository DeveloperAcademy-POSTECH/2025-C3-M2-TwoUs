//
//  ProfileModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation

struct ProfileModel: Codable, Identifiable {
    let id: String             // 사용자 ID (예: 1D856A)
    let qrImageURL: String      // QR 코드 이미지 주소
}

