//
//  ProfileView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    
    @State private var userId: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("임시 회원가입")
                .font(.title2)
                .bold()

            TextField("User ID 입력", text: $userId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("가입") {
                Task {
                    await registerDeviceTokenIfNeeded(userId: userId)
                }
            }
            .padding()
            .disabled(userId.isEmpty)
        }
        .padding()
    }

    func registerDeviceTokenIfNeeded(userId: String) async {
        guard let token = UserDefaults.standard.string(forKey: "deviceToken") else {
            print("디바이스 토큰이 아직 저장되지 않았습니다")
            return
        }

        let dto = PostDeviceTokenRequestDTO(deviceToken: token, userId: userId)

        do {
            let resultArray = try await NetworkService.shared.notificationService.postDeviceToken(model: dto)
            guard let first = resultArray.first else {
                print("❌ 디코딩 성공했지만 응답 배열이 비어있습니다")
                return
            }

            print("✅ 등록 성공: \(first.endpointArn)")
            UserDefaults.standard.set(userId, forKey: "userId")

            await MainActor.run {
                coordinator.path = NavigationPath()
                coordinator.path.append(AppRoute.main)
            }
        } catch {
            print("❌ 등록 실패: \(error.localizedDescription)")
        }
    }
}

#Preview {
    RegisterView()
}
