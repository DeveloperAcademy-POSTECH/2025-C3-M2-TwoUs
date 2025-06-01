//
//  PatchNoteTitleRequestDTO.swift
//  EKO-iOS
//
//  Created by 성현 on 5/31/25.
//

import Foundation

struct PatchNoteTitleRequestDTO: Encodable {
    let sessionId: String
    let title: String
}
