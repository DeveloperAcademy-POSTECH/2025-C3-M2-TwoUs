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
    @FocusState private var focusedIndex: Int? // CodeInputView에서 사용하므로 유지
    @State private var isExpanded = false // 키보드 등장에 따른 버튼 확장
    @StateObject private var keyboard = KeyboardObserver() // 키보드 상태 감지
    
    // 드래그 제스처를 위한 상태
    @State private var currentDragTranslation: CGFloat = .zero
    
    // 초기 시트 높이. TextField 활성화 여부에 따라 달라질 수 있음
    private let initialSheetHeight: CGFloat = 220
    // 키보드가 올라왔을 때 예상되는 시트 높이 (EKOButton이 나타나고 키보드 높이를 더한 값)
    // 이 값은 실제 레이아웃에 따라 조정해야 합니다.
    private var expandedSheetContentHeight: CGFloat {
        // "ID 입력" 텍스트 + CodeInputView + (EKOButton이 있을 경우) EKOButton 높이 + 패딩
        let baseContentHeight: CGFloat = 40 + 55 + 20 + 10 // 대략적인 값, 실제 폰트/패딩에 따라 다름
        let buttonHeight: CGFloat = isExpanded ? 50 + 10 : 0 // EKOButton 높이 + 상단 패딩
        return baseContentHeight + buttonHeight
    }


    var body: some View {
        VStack(spacing: 20) {
            // MARK: 드래그 핸들
            // .presentationDragIndicator(.visible) 대체
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.vertical, 8)
                .contentShape(Rectangle()) // 터치 영역 확장
                .gesture(dragGesture) // 드래그 제스처 추가

            Text("ID 입력")
                .font(.title3)
                .fontWeight(.bold)

            CodeInputView(code: $code)
            
            if isExpanded {
                EKOButton(type: .blue, action: {
                    Task {
                        let success = await viewModel.submitManualCode(userAddCode: code)
                        // 시트 닫기
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }

                        if success {
                            // 친구 추가 성공 알림은 AddFriendView의 alert가 처리합니다.
                            // 시트가 닫힌 후, AddFriendView의 viewModel.showSuccessAlert가 true로 설정될 것입니다.
                        } else {
                            // 실패 시 스캐너 재시작
                            viewModel.shouldRestartScanner = true
                        }
                    }
                })
                .transition(.opacity) // 버튼 등장/사라짐 애니메이션
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
                .padding(.top, 10)
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 20) // 하단 패딩
        // 시트 자체의 배경과 코너 라운딩
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight]) // 상단 모서리만 둥글게

        // MARK: - 시트 높이 동적 조절 및 드래그 제스처 적용을 위한 위치 조정
        .offset(y: currentDragTranslation) // 드래그 제스처에 따른 시트 위치 조정
        .animation(.interactiveSpring(), value: currentDragTranslation) // 드래그 애니메이션

        // 키보드 높이에 따른 시트 높이 및 레이아웃 조절
        .onChange(of: keyboard.isKeyboardVisible) { isVisible in
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded = isVisible
            }
            // 키보드 등장 시 시트 높이 업데이트
            DispatchQueue.main.async { // 높이 계산이 다음 렌더링 사이클에서 정확히 이루어지도록 async
                updateSheetHeight()
            }
        }
        .onAppear {
            // 초기 시트 높이 전달
            updateSheetHeight()
            // alert가 떠있는 상태에서 시트가 다시 나타나면 false로 시작하도록
            if viewModel.showAlert {
                isPresented = false // viewModel.showAlert에 따라 isPresented를 초기화할 수 있습니다.
            }
        }
        .onChange(of: code) { _ in
            // 코드 입력 변경 시 높이 조정 필요하다면 (예: EKOButton 등장)
            updateSheetHeight()
        }
        // 시트 닫힘 감지 (CodeInputSheetView가 사라질 때)
        .onDisappear {
            onHeightChanged?(0) // 시트가 사라지면 높이를 0으로 전달
        }
    }
    
    // MARK: - Helper Methods
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // 시트를 위로 당기는 것은 허용하지 않고, 아래로 당길 때만 translation 적용
                currentDragTranslation = max(0, value.translation.height)
            }
            .onEnded { value in
                // 특정 임계값 이상 당기면 시트 닫기
                if value.translation.height > initialSheetHeight / 2 { // 시트 높이의 절반 이상 당기면 닫기
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }
                currentDragTranslation = .zero // 드래그 끝나면 위치 초기화
            }
    }

    private func updateSheetHeight() {
        var calculatedHeight: CGFloat = initialSheetHeight // 기본 높이

        // 키보드가 보이면 확장된 콘텐츠 높이 + 키보드 높이를 사용
        if keyboard.isKeyboardVisible {
            calculatedHeight = expandedSheetContentHeight + keyboard.keyboardHeight
        } else {
            // 키보드가 없을 때는 EKOButton의 유무에 따라 높이 조정
            if isExpanded { // EKOButton이 여전히 표시되어야 한다면 (예: 코드 입력 완료 후)
                calculatedHeight = expandedSheetContentHeight
            } else {
                calculatedHeight = initialSheetHeight
            }
        }

        // onHeightChanged 클로저를 통해 부모 뷰에 최종 높이 전달
        DispatchQueue.main.async {
            onHeightChanged?(calculatedHeight)
        }
    }
}


// MARK: - CodeInputView (변경 없음)
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
                .frame(width: 0, height: 0) // 투명하게 숨김
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
            .contentShape(Rectangle()) // HStack 전체를 탭 가능하게
            .onTapGesture {
                isFocused = true // 탭하면 TextField에 포커스
            }
        }
    }
}

// MARK: - View Extension for specific corner radius
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
