//
//  ProfileView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.supOrange2, Color.supBlue3], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                Spacer()

                VStack(spacing: 27) {
                    Text(viewModel.nickname ?? "닉네임 로딩 중")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 11)

                    if let image = viewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 210, height: 210)
                            .padding(.horizontal, 38)
                    } else if viewModel.isLoading {
                        ProgressView()
                            .frame(width: 210, height: 210)
                    } else {
                        Image(systemName: "qrcode")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 210, height: 210)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 38)
                    }

                    HStack {
                        Text("ID")
                            .font(.title)
                            .fontWeight(.bold)
                        Text(viewModel.userAddCode ?? "로딩 중")
                            .font(.title)
                        Button(action: {
                            UIPasteboard.general.string = viewModel.userAddCode
                        }) {
                            Image(systemName: "square.on.square")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.bottom, 25)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16).fill(Color.white)
                )
                .padding(.bottom, 110)

                Text("ID 입력")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchProfile(userId: "userA123")
            }
        }
    }
}

#Preview {
    ProfileView()
}
