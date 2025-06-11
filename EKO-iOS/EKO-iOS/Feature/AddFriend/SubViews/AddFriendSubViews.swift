//
//  AddFriendSubViews.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI
import AVFoundation

// MARK: - QRScannerView (변경 없음)
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

// MARK: - QRScanOverlayView (변경 없음)
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

// MARK: - CodeInputSheetView (수정됨)
struct CodeInputSheetView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject var viewModel: AddFriendViewModel

    @Binding var isPresented: Bool // 시트의 표시 여부를 제어하는 바인딩
    var onHeightChanged: ((CGFloat) -> Void)? = nil // 부모 뷰로 높이 변화를 알리는 클로저

    @State private var code = ""
    @FocusState private var isInputFocused: Bool // 핵심: 이걸 CodeInputView에 전달
    @State private var isExpanded = false // 키보드 등장에 따른 버튼 확장
    @StateObject private var keyboard = KeyboardObserver()
    @State private var currentDragTranslation: CGFloat = .zero

    private let initialSheetHeight: CGFloat = 220
    private var expandedSheetContentHeight: CGFloat {
        let baseContentHeight: CGFloat = 40 + 55 + 20 + 10
        let buttonHeight: CGFloat = isExpanded ? 50 + 10 : 0
        return baseContentHeight + buttonHeight
    }

    var body: some View {
        VStack(spacing: 20) {
            // MARK: 드래그 핸들
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onEnded { value in
                            let dragY = value.translation.height
                            if dragY < -20 {
                                isInputFocused = true    // 위로 드래그 → 포커스/키보드 올림
                            } else if dragY > 20 {
                                isInputFocused = false   // 아래로 드래그 → 포커스/키보드 내림
                            }
                        }
                )

            Text("ID 입력")
                .font(.title3)
                .fontWeight(.bold)

            // 핵심: FocusState 바인딩을 CodeInputView에 넘김!
            CodeInputView(code: $code, isInputFocused: $isInputFocused)
            
            if isExpanded {
                EKOButton(type: .blue, action: {
                    Task {
                        let success = await viewModel.submitManualCode(userAddCode: code)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                        if success {
                            // 성공 후 알림 등 처리
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
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .offset(y: currentDragTranslation)
        .animation(.interactiveSpring(), value: currentDragTranslation)
        .onChange(of: keyboard.isKeyboardVisible) { isVisible in
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded = isVisible
            }
            DispatchQueue.main.async {
                updateSheetHeight()
            }
        }
        .onAppear {
            updateSheetHeight()
            if viewModel.showAlert {
                isPresented = false
            }
        }
        .onChange(of: code) { _ in
            updateSheetHeight()
        }
        .onDisappear {
            onHeightChanged?(0)
        }
    }
    
    // 기존 드래그 제스처 등은 동일

    private func updateSheetHeight() {
        var calculatedHeight: CGFloat = initialSheetHeight
        if keyboard.isKeyboardVisible {
            calculatedHeight = expandedSheetContentHeight + keyboard.keyboardHeight
        } else {
            calculatedHeight = isExpanded ? expandedSheetContentHeight : initialSheetHeight
        }
        DispatchQueue.main.async {
            onHeightChanged?(calculatedHeight)
        }
    }
}

// MARK: - CodeInputView (FocusState 바인딩 전달 버전)
struct CodeInputView: View {
    @Binding var code: String
    @FocusState.Binding var isInputFocused: Bool // 부모에서 바인딩 받음

    var body: some View {
        ZStack {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isInputFocused) // 핵심: 부모와 공유 포커스!
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
                isInputFocused = true
            }
        }
    }
}

// MARK: - View Extension (생략 가능)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// `EKOButton`은 프로젝트에 정의되어 있어야 합니다.
// 예를 들어:
/*
struct EKOButton: View {
    enum ButtonType {
        case blue
        case gray
    }
    
    var type: ButtonType
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("버튼 텍스트") // 실제 EKOButton 텍스트에 따라 변경
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(type == .blue ? Color.blue : Color.gray)
                .cornerRadius(10)
        }
    }
}
*/
