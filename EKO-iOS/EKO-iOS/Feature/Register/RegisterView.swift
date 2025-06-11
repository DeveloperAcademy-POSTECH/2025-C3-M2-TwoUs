//
//  ProfileView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI
import AuthenticationServices

struct RegisterView: View {
    // Apple 로그인 결과에 따라 닉네임 입력 필드 노출 여부
    @State private var showNicknameField = false
    @State private var nickname: String = ""
    @State private var isLoading = false
    @State private var appleIdentityToken: String?
    
    var body: some View {
        // 1. 배경 그라데이션
        ZStack {
            LinearGradient(
                colors: [Color.supOrange3, Color.supBlue4],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 2. 카드 박스
            VStack {
                Spacer()
                VStack(spacing: 32) {
                    // 3. 마이크 이모지 & 타이틀
                    VStack(spacing: 3) {
                        Color.clear.frame(height: 100)
                        Image("mic_blue")
                            .resizable()                  // 이미지 리사이즈 허용
                            .frame(width: 70, height: 70) // 원하는 사이즈로 지정
                            .aspectRatio(contentMode: .fit) // 비율 유지 (선택적)
                        Text("회원가입")
                            .font(.title2)
                            .bold()
                    }
                    Spacer()
                    // 4. Apple로 등록 버튼(처음에만 보임)
                    if !showNicknameField {
                        SignInWithAppleButton(.signUp) { request in
                            request.requestedScopes = [.email, .fullName]
                        } onCompletion: { result in
                            switch result {
                            case .success(let auth):
                                if let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                                   let tokenData = credential.identityToken,
                                   let token = String(data: tokenData, encoding: .utf8) {
                                    self.appleIdentityToken = token
                                    withAnimation {
                                        self.showNicknameField = true
                                    }
                                }
                            case .failure(let error):
                                print("❌ Apple 로그인 실패: \(error)")
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 48)
                        .padding(.horizontal, 16)
                    }
                    
                    // 5. 닉네임 입력 & 버튼(Apple 성공 시)
                    if showNicknameField {
                        VStack(spacing: 60) {
                            VStack {
                                HStack {
                                    Text("닉네임")
                                        .padding(.trailing, 20)
                                    TextField("닉네임을 적어주세요", text: $nickname)
                                }
                                .padding(.top, 20)
                                .padding(.horizontal, 20)
                                
                                Divider() // 밑줄 역할
                                        .background(Color.gray.opacity(0.4)) // 줄 색상
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 20)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    // 가입완료 처리
                                    registerAppleUser()
                                }) {
                                    Text("가입완료")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color("mainBlue"))
                                        .foregroundColor(.white)
                                        .cornerRadius(30)
                                }
                                .disabled(nickname.isEmpty || appleIdentityToken == nil)
                                
                                Button(action: {
                                    // 취소: 초기화
                                    withAnimation {
                                        showNicknameField = false
                                        nickname = ""
                                    }
                                }) {
                                    Text("취소")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(30)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 200)
                    }
                    
                    if isLoading {
                        ProgressView()
                    }
                }
                .padding(.bottom, 70)
                .frame(maxWidth: 340)
 
                .cornerRadius(24)
                .shadow(radius: 10)
                Spacer()
            }
            .padding()
        }
    }
    
    
    // 실제 가입 처리 함수 (네트워크 등)
    func registerAppleUser() {
        guard let idToken = appleIdentityToken, !nickname.isEmpty else { return }
        isLoading = true
        // 네트워크 요청 로직 삽입 (비동기)
        // 완료 시 isLoading = false, 화면 전환 등
    }
}

#Preview {
    RegisterView()
}
