//
//  AddFriendSubViews.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    var onFoundQRCode: (String) -> Void
    @Binding var restartTrigger: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(onFound: onFoundQRCode)
    }

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.delegate = context.coordinator
        context.coordinator.controller = vc
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        if restartTrigger {
            print("🔁 [QRScannerView] Triggered restartScanning()")
            uiViewController.restartScanning()
            DispatchQueue.main.async {
                restartTrigger = false
            }
        }
    }

    class Coordinator: NSObject, QRCodeScannerDelegate {
        let onFound: (String) -> Void
        weak var controller: ScannerViewController?

        init(onFound: @escaping (String) -> Void) {
            self.onFound = onFound
        }

        func didFind(code: String) {
            onFound(code)
        }
    }
}

struct QRScanOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.6
            let rect = CGRect(
                x: (geometry.size.width - size) / 2,
                y: (geometry.size.height - size) / 2,
                width: size,
                height: size
            )

            Path { path in
                path.addRoundedRect(in: rect, cornerSize: CGSize(width: 16, height: 16))
            }
            .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [10]))
        }
    }
}

struct CodeInputSheetView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject var viewModel: AddFriendViewModel

    @Binding var isPresented: Bool
    var onHeightChanged: ((CGFloat) -> Void)? = nil

    @State private var code = ""
    @FocusState private var focusedIndex: Int?
    @State private var isExpanded = false
    @StateObject private var keyboard = KeyboardObserver()
    @State private var showSheet = true

    var body: some View {
        VStack(spacing: 20) {
            Text("ID 입력")
                .font(.title3)
                .fontWeight(.bold)

            CodeInputView(code: $code)

            if isExpanded {
                EKOButton(type: .blue, action: {
                    Task {
                        let success = await viewModel.submitManualCode(userAddCode: code)
                        isPresented = false

                        if success {
                            isPresented = false

                            try? await Task.sleep(nanoseconds: 300_000_000)
                            viewModel.showAlert = true
                        } else {
                            viewModel.shouldRestartScanner = true
                        }
                    }
                })
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
                .padding(.top, 10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .interactiveDismissDisabled(true)
        .presentationDetents([.height(220)])
        .presentationCornerRadius(20)
        .presentationDragIndicator(.visible)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        onHeightChanged?(proxy.size.height)
                    }
                    .onChange(of: proxy.size.height) { newHeight in
                        onHeightChanged?(newHeight)
                    }
            }
        )
        .onChange(of: keyboard.isKeyboardVisible) { isVisible in
            withAnimation {
                isExpanded = isVisible
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
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

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showSheet = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.shouldRestartScanner = true
                    }
                }
            )
        }
    }
}


struct CodeInputView: View {
    @Binding var code: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .onChange(of: code) { newValue in
                    code = newValue.filter(\.isWholeNumber).prefix(6).map(String.init).joined()
                }
                .frame(width: 0, height: 0)
                .opacity(0.01)

            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { i in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                            .frame(width: 45, height: 55)

                        Text(code.count > i ? String(code[code.index(code.startIndex, offsetBy: i)]) : "")
                            .font(.title2)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }
        }
    }
}
