//
//  EKOToggleIndicator.swift
//  EKO-iOS
//
//  Created by mini on 6/2/25.
//

import SwiftUI

enum ToggleType {
    case downDirection, upDirection
    
    var title: String {
        switch self {
        case .downDirection: return "Note"
        case .upDirection: return "Record"
        }
    }
    
    var icon: Image {
        switch self {
        case .downDirection: return Image(.toggleDown)
        case .upDirection: return Image(.toggleUp)
        }
    }
}

struct ToggleItemView: View {
    private let type: ToggleType
    
    init(type: ToggleType) {
        self.type = type
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(type.title)
                .font(.textRegular05)
                .foregroundColor(.neutrals3)
            
            type.icon
        }
    }
}
