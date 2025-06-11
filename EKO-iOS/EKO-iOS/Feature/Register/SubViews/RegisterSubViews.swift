//
//  ProfileSubViews.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI
import AuthenticationServices

struct SignInWithAppleButtonView: View {
    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    handleAuthResults(authResults)
                case .failure(let error):
                    print("🍎 Apple 로그인 실패: \(error.localizedDescription)")
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .cornerRadius(10)
        .padding()
    }

    private func handleAuthResults(_ authResults: ASAuthorization) {
        guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            print("❌ identityToken 추출 실패")
            return
        }

        print("🍏 Apple identityToken: \(identityToken)")

        Task {
            await federateToCognito(appleToken: identityToken)
        }
    }
    
    func federateToCognito(appleToken: String) async {
        let identityPoolId = "ap-northeast-2:your-identity-pool-id"
        let loginsKey = "appleid.apple.com"

        let getIdUrl = "https://cognito-identity.ap-northeast-2.amazonaws.com/"
        let payload: [String: Any] = [
            "IdentityPoolId": identityPoolId,
            "Logins": [loginsKey: appleToken]
        ]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: payload),
              let url = URL(string: getIdUrl) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-amz-json-1.1", forHTTPHeaderField: "Content-Type")
        request.setValue("AWSCognitoIdentityService.GetId", forHTTPHeaderField: "X-Amz-Target")
        request.httpBody = bodyData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let result = try JSONDecoder().decode(GetIdResponse.self, from: data)
            print("✅ IdentityId 획득: \(result.IdentityId)")

            UserDefaults.standard.set(result.IdentityId, forKey: "userId")

        } catch {
            print("❌ Cognito GetId 실패: \(error)")
        }
    }

    struct GetIdResponse: Decodable {
        let IdentityId: String
    }
}

#Preview {
    SignInWithAppleButtonView()
}
