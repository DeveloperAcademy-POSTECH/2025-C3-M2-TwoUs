//
//  ProfileView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI
import AuthenticationServices

struct RegisterView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var nickname: String = ""
    @State private var showNicknameField = false
    @State private var appleIdentityToken: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Text("EKO: 한문장 말하는 뭐시기")
                .font(.title2)
                .bold()

            SignInWithAppleButton(.signUp) { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                switch result {
                case .success(let auth):
                    if let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                       let tokenData = credential.identityToken,
                       let token = String(data: tokenData, encoding: .utf8) {
                        self.appleIdentityToken = token
                        self.showNicknameField = true
                    }
                case .failure(let error):
                    print("❌ Apple 로그인 실패: \(error)")
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding(.horizontal)

            if showNicknameField {
                TextField("닉네임 입력", text: $nickname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("가입 완료") {
                    Task {
                        await registerAppleUser()
                    }
                }
                .disabled(nickname.isEmpty || appleIdentityToken == nil)
            }

            if isLoading {
                ProgressView()
            }
        }
        .padding()
    }

    func registerAppleUser() async {
        guard let idToken = appleIdentityToken,
              let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") else {
            print("❌ 토큰 누락")
            return
        }

        let dto = PostAppleSignupRequestDTO(idToken: idToken, nickname: nickname, deviceToken: deviceToken)

        isLoading = true
        do {
            let result = try await NetworkService.shared.userService.postAppleSignup(model: dto)
            UserDefaults.standard.set(result.userId, forKey: "userId")

            await MainActor.run {
                coordinator.path = NavigationPath()
                coordinator.path.append(AppRoute.main)
            }
        } catch {
            print("❌ 회원가입 실패: \(error)")
        }
        isLoading = false
    }
}

#Preview {
    RegisterView()
}
