//
//  SwiftUIView.swift
//  EKO-iOS
//
//  Created by 성현 on 6/12/25.
//

import SwiftUI
import Lottie

struct ControllableLottieView: UIViewRepresentable {
    let animationName: String
    @Binding var isPlaying: Bool

    let animationView = LottieAnimationView()

    func makeUIView(context: Context) -> UIView {
        animationView.animation = LottieAnimation.named(animationName)
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 0.7
        animationView.backgroundBehavior = .pauseAndRestore
        return animationView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if isPlaying {
            animationView.play()
        } else {
            animationView.stop()
        }
    }
}
struct FingerprintButton: View {
    //롱프레스  제스처 상태
    @GestureState var press = false
    //롱프레스 제스쳐 완료 상태 체크
    @State var completed = false
    var body: some View {
        //3개의 이미지 와 원형 상태바 레이어용 ZStack
        ZStack {
            //1. 기본 배경 - 완료시 사라짐
            Image("fingerprint1")
                .opacity(completed ? 0 : 1)
                .scaleEffect(completed ? 0 : 1)
            
            //2. 진행 중에 위로 이동하면서 애니메이션
            Image("fingerprint2")
                .clipShape(
                    Circle()
                        .offset(y: press ? 0 : 50)
                )
                .animation(.easeOut)
            
            //3. 완료 시 커지면서 화면에 보여짐
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 44, weight: .light))
                .foregroundColor(Color(#colorLiteral(red: 0.5175917745, green: 0.549059689, blue: 0.8116646409, alpha: 1)))
                .opacity(completed ? 1 : 0)
                .scaleEffect(completed ? 1 : 0)
            
            //진행 상태 바
            Circle()
                .trim(from: press ? 0.001 : 1, to: 1)
                .stroke(Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 88, height: 88)
                .rotationEffect(Angle(degrees: 90))
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .animation(.easeInOut)
        }
        .frame(width: 120, height: 120)
        .background(
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5764705882, green: 0.7098039216, blue: 0.8823529412, alpha: 1)), Color(#colorLiteral(red: 0.9647058824, green: 0.9607843137, blue: 0.9607843137, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            }
            
        )
        //위쪽 광원
        .shadow(color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), radius: 20, x: -20, y: -20)
        //아래쪽 음영
        .shadow(color: Color(#colorLiteral(red: 0.5764705882, green: 0.7098039216, blue: 0.8823529412, alpha: 1)), radius: 20, x: 20, y: 20)
        
        //Long Press Gesture 이벤트 처리
        .gesture(LongPressGesture()
                    .updating($press){ (currentState, gestureState, _) in
                        gestureState = currentState
                    }
                    .onEnded { _ in
                        self.completed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.completed = false
                        }
                        //self.press.toggle()
                    }
        )
    }
}
