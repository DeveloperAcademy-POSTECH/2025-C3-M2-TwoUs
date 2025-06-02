//
//  EKOFriendsView.swift
//  EKO-iOS
//
//  Created by mini on 6/2/25.
//

import SwiftUI

public enum EKOFriendsViewType {
    case request
    case response
    
    var tintColor: Color {
        switch self {
        case .request:
            return .mainOrange
        case .response:
            return .mainBlue
        }
    }
}

struct EKOFriendsView: View {
    private let type: EKOFriendsViewType
    private let name: String
    private(set) var isSelected: Bool
    private(set) var isSended: Bool
    
    public init(
        type: EKOFriendsViewType,
        name: String,
        isSelected: Bool = false,
        isSended: Bool = false
    ) {
        self.type = type
        self.name = name
        self.isSelected = isSelected
        self.isSended = isSended
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if type == .request {
                Text(name)
                    .font(.title03)
                    .foregroundStyle(isSelected ? type.tintColor : .neutrals3)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.mainWhite)
                    .cornerRadius(15)
                    .overlay {
                        Capsule()
                            .stroke(
                                isSelected ? type.tintColor : .neutrals3,
                                lineWidth: 1
                            )
                    }
            } else {
                Text.styledText(
                    fullText: "\(name)의 질문",
                    highlightedText: name,
                    baseColor: isSelected ? type.tintColor : .neutrals3,
                    baseFont: .textRegular02,
                    highlightedColor: isSelected ? type.tintColor : .neutrals3,
                    highlightedFont: .title03
                )
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(.mainWhite)
                .cornerRadius(15)
                .overlay {
                    Capsule()
                        .stroke(
                            isSelected ? type.tintColor : .neutrals3,
                            lineWidth: 1
                        )
                }
            }
            
            if isSended {
                ZStack {
                    Circle()
                        .fill(Color.mainWhite)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? type.tintColor : .neutrals3, lineWidth: 1)
                        )

                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(isSelected ? type.tintColor : .neutrals3)
                }
                .offset(x: 8, y: -8)
            }
        }
    }
}
