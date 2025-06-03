//
//  View+.swift
//  EKO-iOS
//
//  Created by mini on 6/2/25.
//

import SwiftUI

extension View {
    /// View의 배경색을 그라디언트 색상을 적용해서 만들 수 있도록 도와주는 Extension Method
    func setupGradientBackground(colors: [Color]) -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    /// EKOToastMessage를 원하는 시간동안 보였다가 자동으로 사라지도록 만드는 Extension Method
    func showToast(
        toastType: EKOToastType?,
        isShowing: Binding<Bool>,
        bottomPadding: CGFloat,
        duration: TimeInterval = 3.0
    ) -> some View {
        ZStack {
            self

            if isShowing.wrappedValue, let type = toastType {
                VStack {
                    Spacer()

                    EKOToastMessage(toastType: type)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, bottomPadding)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isShowing.wrappedValue = false
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: isShowing.wrappedValue)
    }
}
