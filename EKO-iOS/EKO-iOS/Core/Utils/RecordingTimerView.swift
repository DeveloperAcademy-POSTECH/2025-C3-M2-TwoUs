//
//  RecordingTimerView.swift
//  EKO-iOS
//
//  Created by Seungeun Park on 6/11/25.
//

import SwiftUI

struct RecordingTimerView: View {
    let time: Int
    let color: Color

    var body: some View {
        Text(String(format: "%02d:%02d", time / 60, time % 60))
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(color)
            .padding(.top, 40)
            .transition(.opacity)
    }
}
