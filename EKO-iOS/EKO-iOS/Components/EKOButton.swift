//
//  EKOButton.swift
//  EKO-iOS
//
//  Created by mini on 6/2/25.
//

import SwiftUI

public enum EKOButtonType {
    case white, blue
    
    var title: String {
        switch self {
        case .white: return "내 발음 들려주기"
        case .blue: return "추가하기"
        }
    }
    
    var backgroundColor: [Color] {
        switch self {
        case .white:
            return [.mainWhite.opacity(0.9), .mainWhite.opacity(0.5), .mainWhite.opacity(0.9)]
        case .blue:
            return [.mainBlue]
        }
    }
    
    var textColor: Color {
        switch self {
        case .white:
            return .mainBlue
        case .blue:
            return .white
        }
    }
}

struct EKOButton: View {
    @Environment(\.isEnabled) private var isEnabled
    
    private let type: EKOButtonType
    private let action: () -> Void
        
    public init(
        type: EKOButtonType,
        action: @escaping () -> Void
    ) {
        self.type = type
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(type.title)
                .font(.button01)
                .padding(.vertical, 16)
                .padding(.horizontal, 33)
                .frame(width: 193, height: 55)
                .foregroundStyle(isEnabled ? type.textColor : .mainWhite)
                .setupGradientBackground(colors: isEnabled ? type.backgroundColor : [.neutrals4])
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay {
                    if type == .white {
                        Capsule()
                            .stroke(Color.mainWhite, lineWidth: 1)
                    }
                }
        }
    }
}
