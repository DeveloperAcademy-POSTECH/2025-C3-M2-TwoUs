//  AddFriendView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.

import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = AddFriendViewModel()
    @State private var showCustomSheet = true // .sheet 대신 이 상태 변수를 사용합니다.
    @State private var sheetHeight: CGFloat = 220 // CodeInputSheetView에서 전달받는 높이
    @StateObject private var keyboard = KeyboardObserver()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) { // 시트가 하단에서 올라오므로 .bottom 정렬
                QRScannerView(
                    onFoundQRCode: { code in
                        viewModel.handleScanned(code: code)
                        // QR 코드 스캔 시 시트 닫기 (필요하다면)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showCustomSheet = false
                        }
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
                // 오버레이 및 배경 애니메이션은 여기서 처리 가능
                .animation(.easeInOut(duration: 0.3), value: sheetHeight) // 시트 높이 변화에 따른 오버레이 위치 조정 애니메이션
                .animation(.easeInOut(duration: 0.3), value: keyboard.isKeyboardVisible) // 키보드 상태 변화에 따른 애니메이션
                
                // MARK: - 커스텀 시트 배경 딤(Dim) 효과
                if showCustomSheet {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if keyboard.isKeyboardVisible {
                                // 1. 키보드가 보이면 키보드만 내리기
                                hideKeyboard()
                            } 
                        }
                }
                
                

                // MARK: - 커스텀 시트 뷰 (CodeInputSheetView)
                if showCustomSheet {
                    CodeInputSheetView(isPresented: $showCustomSheet) { newHeight in
                        // CodeInputSheetView에서 시트 높이를 전달받습니다.
                        self.sheetHeight = newHeight
                    }
                    .environmentObject(viewModel)
                    .offset(y: -keyboard.keyboardHeight)
                    .animation(.easeInOut(duration: 0.3), value: keyboard.keyboardHeight)
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
        // 이 alert은 viewModel.showSuccessAlert에 반응
        .alert("친구가 추가되었습니다!", isPresented: $viewModel.showSuccessAlert) {
            Button("확인") {
                coordinator.push(.profile)
            }
        }
        // CodeInputSheetView에서 취소 버튼을 눌렀을 때 시트와 스캐너를 다시 띄우는 로직은 여기서 처리합니다.
        // viewModel.showAlert는 QR 스캔 후 친구 추가 여부를 묻는 alert를 위해 AddFriendView에서만 관리합니다.
        .alert(isPresented: $viewModel.showAlert) { // QR 스캔 후 친구 추가 여부 묻는 Alert
            Alert(
                title: Text(viewModel.scannedUserNickname ?? "알 수 없음"),
                message: Text("친구를 추가하시겠습니까?"),
                primaryButton: .default(Text("추가")) {
                    Task {
                        await viewModel.submitCodeAndAddFriend(myUserId: "userA123", myNickname: "테스트 유저 1")
                    }
                },
                secondaryButton: .cancel(Text("취소")) {
                    print("❌ [AddFriendView] Alert 취소 → 딜레이 후 시트 + 스캐너 재시작")
                    
                    // 시트 다시 띄우기
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCustomSheet = true
                    }
                    
                    // 스캐너 재시작
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.shouldRestartScanner = true
                    }
                }
            )
        }
    }

    private func calculateVerticalOffset(in fullHeight: CGFloat) -> CGFloat {
        // QR 스캔 오버레이의 위치를 조정하는 로직
        // 키보드 높이와 시트 높이를 고려하여 오버레이가 적절한 위치에 오도록 합니다.
        // keyboard.keyboardHeight가 실제 키보드 높이를 반환해야 합니다.
        let keyboardHeight: CGFloat = keyboard.isKeyboardVisible ? keyboard.keyboardHeight : 0
        let usableHeight = fullHeight - sheetHeight - keyboardHeight
        return max(usableHeight / 2 - 125, 0) // 125는 QRScanOverlayView 높이의 절반 (250/2)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

