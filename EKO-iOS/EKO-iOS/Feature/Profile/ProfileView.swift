//
//  ProfileView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

struct ProfileView: View {
    // 임시 더미 데이터 생성
    let dummyProfile = ProfileModel(
        id: "1D856A",
        qrImageURL: "dummyQR"
    )
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.supOrange2, Color.supBlue3],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                VStack(spacing: 27) {
                    Text("MINI")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 11)
                    
                    Image(dummyProfile.qrImageURL)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210, height: 210)
                        .padding(.horizontal, 38)
                    
                    HStack {
                        Text("ID:")
                            .font(.title)
                            .fontWeight(.bold)
                        Text(dummyProfile.id)
                            .font(.title)
                        Button(action: {
                            UIPasteboard.general.string = dummyProfile.id
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
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white) // 하얀 배경
                )
                .padding(.bottom, 110)
                
                Text("ID 입력")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 50)
            }
        }
    }
}
#Preview {
    ProfileView()
}
