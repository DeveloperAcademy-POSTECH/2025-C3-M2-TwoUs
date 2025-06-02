//
//  EKOToastMessage.swift
//  EKO-iOS
//
//  Created by mini on 6/2/25.
//

import SwiftUI

public enum EKOToastType {
    case completeQuestion
    case completeAnswer
    case invalidQRCode
    
    /// 토스트에 들어갈 유형별 메시지
    var message: String {
        switch self {
        case .completeQuestion, .completeAnswer:
            return "전송이 완료되었습니다."
        case .invalidQRCode:
            return "유효하지 않은 QR입니다."
        }
    }
    
    /// 토스트에 들어갈 아이콘 (SF Symbols)
    var iconName: String? {
        switch self {
        case .completeQuestion, .completeAnswer:
            return "paperplane.fill"
        default: return nil
        }
    }
    
    /// 토스트 아이콘 색상
    var iconColor: Color {
        switch self {
        case .completeAnswer:
            return .mainOrange
        case .completeQuestion:
            return .mainBlue
        case .invalidQRCode:
            return .mainWhite
        }
    }
}

struct EKOToastMessage: View {
    private let toastType: EKOToastType
    
    init(toastType: EKOToastType) {
        self.toastType = toastType
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let circleImageName = toastType.iconName {
                Circle()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(.mainWhite)
                    .overlay {
                        Image(systemName: circleImageName)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(toastType.iconColor)
                            .frame(width: 12, height: 12)
                    }
            }

            Text(toastType.message)
                .font(.textSemiBold02)
                .foregroundColor(.neutrals2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .setupGradientBackground(colors: [
            .mainWhite.opacity(0.8), .mainWhite.opacity(0.5)
        ])
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}
