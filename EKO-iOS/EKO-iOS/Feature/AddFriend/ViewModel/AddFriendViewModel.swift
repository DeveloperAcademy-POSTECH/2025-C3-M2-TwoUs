//  AddFriendViewModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.

import Foundation

@MainActor
final class AddFriendViewModel: ObservableObject {
    @Published var scannedUserNickname: String?
    @Published var scannedUserId: String?
    @Published var showAlert: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var codeInput: String = ""
    @Published var shouldRestartScanner: Bool = false {
        didSet {
            print("📡 [ViewModel] shouldRestartScanner = \(shouldRestartScanner)")
        }
    }

    let userService: UserAPIServiceProtocol = UserAPIService()

    /// QR 또는 수동 코드 입력 처리 (공통)
    func handleScanned(code: String) {
        guard let data = code.data(using: .utf8),
              let parsed = try? JSONDecoder().decode(QRData.self, from: data) else {
            print("유효하지 않은 QR입니다")
            return
        }

        Task {
            await fetchFriendProfile(userAddCode: String(parsed.userAddCode))
        }
    }

    /// 수동 코드 입력 처리
    func submitManualCode(userAddCode: String) async -> Bool {
        do {
            let result = try await userService.fetchFriendsProfile(userAddCode: userAddCode)
            await MainActor.run {
                self.scannedUserNickname = result.nickname
                self.scannedUserId = result.userId
            }
            return true
        } catch {
            print("유효하지 않은 코드입니다: \(error)")
            return false
        }
    }

    /// 친구 프로필 요청 공통 함수
    func fetchFriendProfile(userAddCode: String) async {
        do {
            let result = try await userService.fetchFriendsProfile(userAddCode: userAddCode)

            await MainActor.run {
                self.scannedUserNickname = result.nickname
                self.scannedUserId = result.userId
                self.showAlert = true
            }
        } catch {
            print("유효하지 않은 코드입니다: \(error)")
        }
    }

    /// 최종 친구 추가 요청
    func submitCodeAndAddFriend(myUserId: String, myNickname: String) async {
        guard let friendId = scannedUserId,
              let friendNickname = scannedUserNickname else {
            print("친구 정보가 유효하지 않음")
            return
        }

        let request = PostNewFriendsRequestDTO(
            myUserId: myUserId,
            friendUserId: friendId,
            myNickname: myNickname,
            friendNickname: friendNickname
        )

        do {
            let _ = try await userService.postNewfriendsRequest(model: request)
            self.showSuccessAlert = true
        } catch {
            print("친구 추가 실패: \(error)")
        }
    }
}
