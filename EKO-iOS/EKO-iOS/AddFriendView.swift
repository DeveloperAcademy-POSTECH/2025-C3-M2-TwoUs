//
//  AddFriendView.swift
//  EKO-iOS
//
//  Created by 성현 on 6/7/25.
//


import SwiftUI

struct AddFriendView: View {
    @State private var scannedCode: String?
    @State private var scannedNickname: String?
    @State private var scannedUserId: String?
    @State private var showAlert = false

    var body: some View {
        VStack {
            if let code = scannedCode {
                Text("🔍 스캔된 ID: \(code)")
            } else {
                QRScannerView { code in
                    if let data = code.data(using: .utf8),
                       let parsed = try? JSONDecoder().decode(QRData.self, from: data) {
                        print("유효한 QR입니다: \(parsed.userId), \(parsed.userAddCode)")

                        Task {
                            do {
                                let result = try await NetworkService.shared.userService.fetchFriendsProfile(userAddCode: String(parsed.userAddCode))
                                scannedCode = result.userId
                                scannedNickname = result.nickname
                                scannedUserId = result.userId
                                showAlert = true
                            } catch {
                                print("유효하지 않은 QR입니다")
                            }
                        }
                    } else {
                        print("유효하지 않은 QR입니다")
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(scannedNickname ?? "알 수 없음"),
                message: Text("친구를 추가하시겠습니까?"),
                primaryButton: .default(Text("추가")) {
                    print("추가 버튼 클릭: \(scannedUserId ?? "")")
                    // TODO: 친구 추가 API 연결 예정
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
    }
}

#Preview {
    AddFriendView()
}
