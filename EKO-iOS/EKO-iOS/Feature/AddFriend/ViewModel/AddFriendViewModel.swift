//  AddFriendViewModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation
import Combine

class AddFriendViewModel: ObservableObject {
    @Published var friendCodeInput: String = "" // CodeInputSheetView에서 직접 바인딩
    @Published var shouldRestartScanner: Bool = false // QRScannerView 재시작 트리거
    @Published var showAlert: Bool = false // 친구 추가 여부를 묻는 Alert
    @Published var scannedUserNickname: String? // QR 스캔 시 찾은 친구 닉네임
    @Published var showSuccessAlert: Bool = false // 친구 추가 성공 Alert

    private var scannedCode: String?

    // QR 코드 스캔 처리
    func handleScanned(code: String) {
        print("✅ [AddFriendViewModel] Scanned code: \(code)")
        self.scannedCode = code
        // 실제 API 호출로 코드에 해당하는 유저 정보 가져오기
        // 임시로 닉네임 설정
        self.scannedUserNickname = "코드 유저 (\(code.prefix(4))...)"
        self.showAlert = true // 친구 추가 여부 묻는 Alert 띄우기
    }

    // 수동 코드 입력 처리
    func submitManualCode(userAddCode: String) async -> Bool {
        print("➡️ [AddFriendViewModel] Manual code submitted: \(userAddCode)")
        // 여기에 실제 친구 추가 로직 (API 호출 등) 구현
        // 성공/실패 여부를 반환
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기 시뮬레이션
            if userAddCode == "123456" { // 예시: 특정 코드만 성공
                print("👍 [AddFriendViewModel] Manual code success!")
                self.scannedUserNickname = "수동 유저 (\(userAddCode))"
                await submitCodeAndAddFriend(myUserId: "userA123", myNickname: "테스트 유저 1")
                return true
            } else {
                print("👎 [AddFriendViewModel] Manual code failed. Invalid code.")
                // 실패 시 사용자에게 알림 (필요하다면)
                return false
            }
        } catch {
            print("🚨 [AddFriendViewModel] Manual code submission error: \(error.localizedDescription)")
            return false
        }
    }

    // 스캔 또는 수동 입력 후 친구 추가 확정
    func submitCodeAndAddFriend(myUserId: String, myNickname: String) async {
        print("🤝 [AddFriendViewModel] Attempting to add friend...")
        guard let codeToSubmit = scannedCode ?? (friendCodeInput.isEmpty ? nil : friendCodeInput) else {
            print("🚫 [AddFriendViewModel] No code to submit.")
            return
        }
        
        // 실제 친구 추가 API 호출 로직
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5초 대기 시뮬레이션
            print("🎉 [AddFriendViewModel] Friend added successfully with code: \(codeToSubmit)")
            self.showSuccessAlert = true // 친구 추가 성공 알림
            // 성공 후 필요한 초기화 또는 내비게이션
            self.scannedCode = nil
            self.friendCodeInput = ""
            self.showAlert = false // 기존 alert 숨김
            self.shouldRestartScanner = false // 스캐너 재시작 방지 (성공했으니)
        } catch {
            print("❌ [AddFriendViewModel] Failed to add friend: \(error.localizedDescription)")
            // 실패 시 처리
            self.scannedCode = nil
            self.friendCodeInput = ""
            self.showAlert = false
            self.shouldRestartScanner = true // 스캐너 재시작
        }
    }
}
