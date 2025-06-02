//
//  EKOTabSelector.swift
//  EKO-iOS
//
//  Created by mini on 6/2/25.
//

import SwiftUI

enum EKOTab: String, CaseIterable {
    case question = "질문하기"
    case answer = "답변하기"
}

struct EKOTabSelector: View {
    @Binding var selected: EKOTab
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(EKOTab.allCases, id: \.self) { tab in
                Button(
                    action: { selected = tab }
                ) {
                    Text(tab.rawValue)
                        .font(selected == tab ? .title01 : .textRegular01)
                        .foregroundColor(selected == tab ? .neutrals1 : .neutrals3)
                }
                
                if tab == .question {
                    Text("|")
                        .foregroundStyle(.neutrals4)
                }
            }
        }
    }
}
