//
//  ProfileView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.supOrange2, Color.supBlue3], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: {
                        coordinator.push(.main)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding()
                    }

                    Spacer()

                    Button(action: {
                        coordinator.push(.addFriend)
                    }) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding()
                    }
                }
                .padding(.horizontal)

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
                
                Spacer()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchProfile(userId: "userA123")
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    ProfileView()
}
