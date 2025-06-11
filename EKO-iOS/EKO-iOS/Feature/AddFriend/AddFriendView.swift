//  AddFriendView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.

import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = AddFriendViewModel()
    @State private var showCustomSheet = true
    @State private var sheetHeight: CGFloat = 220
    @StateObject private var keyboard = KeyboardObserver()

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                
                // MARK: - QR 스캐너 미리보기 (배경)
                QRScannerView(
                    onFoundQRCode: { code in
                        viewModel.handleScanned(code: code)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showCustomSheet = false
                        }
                    },
                    restartTrigger: $viewModel.shouldRestartScanner
                )
                .ignoresSafeArea()

                // MARK: - QR 오버레이(스캔 가이드)
                VStack {
                    Spacer()
                        .frame(height: calculateVerticalOffset(in: geometry.size.height))
                    QRScanOverlayView()
                        .frame(width: 250, height: 250)
                        .padding(.top, 100)
                    Spacer()
                }
                .animation(.easeInOut(duration: 0.3), value: sheetHeight)
                .animation(.easeInOut(duration: 0.3), value: keyboard.isKeyboardVisible)

                // MARK: - 커스텀 시트 배경 딤(Dim)
                if showCustomSheet {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if keyboard.isKeyboardVisible {
                                hideKeyboard()
                            }
                        }
                }

                // MARK: - 커스텀 시트 (코드 입력)
                if showCustomSheet {
                    CodeInputSheetView(isPresented: $showCustomSheet) { newHeight in
                        self.sheetHeight = newHeight
                    }
                    .environmentObject(viewModel)
                    .offset(y: -keyboard.keyboardHeight)
                    .animation(.easeInOut(duration: 0.3), value: keyboard.keyboardHeight)
                }

                // MARK: - 커스텀 네비게이션 바 (상단 고정)
                VStack {
                    HStack {
                        Text("친구추가")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            coordinator.pop()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(10) // 터치 영역 확장
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 20)
                    .background(Color.clear)
                    Spacer()
                }
                // alignment: .top이 아니라, VStack의 첫 번째 HStack이 상단에 고정됨
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .ignoresSafeArea(.all, edges: .top)
        }
        .navigationBarHidden(true)            // 기본 네비게이션바/뒤로가기 버튼 숨김
        .navigationBarBackButtonHidden(true)  // (iOS 16~)

        // 친구 추가 성공 알림
        .alert("친구가 추가되었습니다!", isPresented: $viewModel.showSuccessAlert) {
            Button("확인") {
                coordinator.push(.profile)
            }
        }
        // QR 스캔 후 친구 추가 여부 묻는 Alert
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.scannedUserNickname ?? "알 수 없음"),
                message: Text("친구를 추가하시겠습니까?"),
                primaryButton: .default(Text("추가")) {
                    Task {
                        await viewModel.submitCodeAndAddFriend(myUserId: UserDefaults.standard.string(forKey: "userId") ?? "", myNickname: UserDefaults.standard.string(forKey: "nickname") ?? "")
                    }
                },
                secondaryButton: .cancel(Text("취소")) {
                    print("❌ [AddFriendView] Alert 취소 → 딜레이 후 시트 + 스캐너 재시작")
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCustomSheet = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.shouldRestartScanner = true
                    }
                }
            )
        }
    }

    private func calculateVerticalOffset(in fullHeight: CGFloat) -> CGFloat {
        let keyboardHeight: CGFloat = keyboard.isKeyboardVisible ? keyboard.keyboardHeight : 0
        let usableHeight = fullHeight - sheetHeight - keyboardHeight
        return max(usableHeight / 2 - 125, 0)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
