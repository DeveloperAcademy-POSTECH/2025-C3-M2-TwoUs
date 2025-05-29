//
//  Font+.swift
//  EKO-iOS
//
//  Created by mini on 5/28/25.
//

import SwiftUI

enum FontName: String {
    case pretendardBold = "Pretendard-Bold"
    case pretendardSemiBold = "Pretendard-SemiBold"
    case pretendardMedium = "Pretendard-Medium"
    case pretendardRegular = "Pretendard-Regular"
}

extension Font {
    static let title01: Font = .custom(FontName.pretendardBold.rawValue, size: 24)
    static let title02: Font = .custom(FontName.pretendardBold.rawValue, size: 20)
    static let title03: Font = .custom(FontName.pretendardBold.rawValue, size: 18)
    
    static let textSemiBold01: Font = .custom(FontName.pretendardSemiBold.rawValue, size: 16)
    static let textSemiBold02: Font = .custom(FontName.pretendardSemiBold.rawValue, size: 14)
    static let textSemiBold03: Font = .custom(FontName.pretendardSemiBold.rawValue, size: 12)

    static let textRegular01: Font = .custom(FontName.pretendardRegular.rawValue, size: 20)
    static let textRegular02: Font = .custom(FontName.pretendardRegular.rawValue, size: 18)
    static let textRegular03: Font = .custom(FontName.pretendardRegular.rawValue, size: 16)
    static let textRegular04: Font = .custom(FontName.pretendardRegular.rawValue, size: 14)
    static let textRegular05: Font = .custom(FontName.pretendardRegular.rawValue, size: 12)

    static let button01: Font = .custom(FontName.pretendardBold.rawValue, size: 16)
    static let button02: Font = .custom(FontName.pretendardMedium.rawValue, size: 14)
}
