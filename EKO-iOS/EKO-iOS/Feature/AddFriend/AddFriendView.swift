//  AddFriendView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.

import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = AddFriendViewModel()
    @State private var showSheet = true
    @State private var sheetHeight: CGFloat = 220
    @StateObject private var keyboard = KeyboardObserver()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                QRScannerView(
                    onFoundQRCode: { code in
                        viewModel.handleScanned(code: code)
                    },
                    restartTrigger: $viewModel.shouldRestartScanner
                )
                .ignoresSafeArea()

                VStack {
                    Spacer()
                        .frame(height: calculateVerticalOffset(in: geometry.size.height))

                    QRScanOverlayView()
                        .frame(width: 250, height: 250)

                    Spacer()
                }
                .animation(.easeInOut(duration: 0.3), value: sheetHeight)
                .animation(.easeInOut(duration: 0.3), value: keyboard.isKeyboardVisible)
            }
        }
        .sheet(isPresented: $showSheet) {
            CodeInputSheetView(isPresented: $showSheet) { newHeight in
                sheetHeight = newHeight
            }
            .environmentObject(viewModel)
        }
        .alert("친구가 추가되었습니다!", isPresented: $viewModel.showSuccessAlert) {
            Button("확인") {
                coordinator.push(.profile)
            }
        }

    }

    private func calculateVerticalOffset(in fullHeight: CGFloat) -> CGFloat {
        let keyboardHeight: CGFloat = keyboard.isKeyboardVisible ? 300 : 0
        let usableHeight = fullHeight - sheetHeight - keyboardHeight
        return max(usableHeight / 2 - 125, 0)
    }
}
