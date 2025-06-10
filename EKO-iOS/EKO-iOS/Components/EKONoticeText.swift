//
//  EKONoticeText.swift
//  EKO-iOS
//
//  Created by mini on 6/9/25.
//

import SwiftUI

struct EKONoticeText: View {
    private let title: String
    
    public init(title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.textRegular04)
            .foregroundStyle(.neutrals3)
    }
}

#Preview {
    EKONoticeText(title: "발음 듣고 피드백 보내기")
}
