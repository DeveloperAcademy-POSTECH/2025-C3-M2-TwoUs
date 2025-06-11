//
//  ProfileViewModel.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var userId: String = ""
    @Published var nickname: String = ""
    @Published var userAddCode: String = ""
    @Published var userQrCodeUrl: String = ""
    @Published var profileImage: UIImage?
    @Published var isLoading = false

    func fetchProfile(userId: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await NetworkService.shared.userService.fetchMyprofile(userId: userId)

            self.userId = response.userId
            self.nickname = response.nickname
            self.userAddCode = String(response.userAddCode)
            self.userQrCodeUrl = response.userQrCodeUrl

            await fetchQrImage(from: response.userQrCodeUrl)

        } catch {
            print("❌ 프로필 불러오기 실패: \(error)")
        }
    }

    private func fetchQrImage(from urlString: String) async {
        guard let url = URL(string: urlString) else {
            print("❌ 유효하지 않은 URL: \(urlString)")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            self.profileImage = UIImage(data: data)
        } catch {
            print("❌ 이미지 다운로드 실패: \(error)")
        }
    }
}
