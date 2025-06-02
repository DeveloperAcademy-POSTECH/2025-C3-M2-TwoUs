//
//  EKOEmptyView.swift
//  EKO-iOS
//
//  Created by mini on 6/2/25.
//

import SwiftUI

struct EKOEmptyView: View {
    private var title: String
    private var description: String
    
    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }
    
    var body: some View {
        VStack(spacing: 18) {
            Text(title)
                .font(.title02)
                .foregroundStyle(.neutrals2)
            
            Text(description)
                .multilineTextAlignment(.center)
                .font(.textRegular04)
                .lineSpacing(4)
                .foregroundStyle(.neutrals3)
        }
    }
}

#Preview {
    EKOEmptyView(
        title: "아직 추가된 노트가 없어요.",
        description: "상대방과 피드백을 주고받으면\n해당 화면에서 학습내역을 확인할 수 있어요."
    )
}
