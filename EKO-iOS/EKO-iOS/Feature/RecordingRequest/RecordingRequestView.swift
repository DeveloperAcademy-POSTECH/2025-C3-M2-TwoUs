//
//  RecordingRequestView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI
import Lottie

struct RecordingRequestView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = RecordingRequestViewModel()
    
    @State private var recorder = AudioRecorder()
    @State private var audioPlayer = AudioPlayer()
    @State private var lastRecordedURL: URL?
    @State private var isPressing = false
    @State private var showNote = false
    @State private var dragOffset: CGFloat = .zero

    struct LottieView: UIViewRepresentable {
        let animationName: String
        let loopMode: LottieLoopMode
        func makeUIView(context: Context) -> some UIView {
            let animationView = LottieAnimationView(name: animationName)
            animationView.loopMode = loopMode
            animationView.play()
            animationView.animationSpeed = 0.7
            animationView.contentMode = .scaleAspectFit
            animationView.backgroundBehavior = .pauseAndRestore
            return animationView
        }
        func updateUIView(_ uiView: UIViewType, context: Context) {}
    }

    @ViewBuilder
    private var recordingAnimation: some View {
        if recorder.isRecording {
            LottieView(animationName: "CircleWaveOrange", loopMode: .loop)
                .frame(width: 300, height: 300)
        }
    }

    private var symbolName: String {
        if recorder.isRecording {
            return "stop.fill"
        } else if lastRecordedURL != nil {
            return "restart"
        } else {
            return "mic.fill"
        }
    }

    private var buttonColor: Color {
        symbolName == "mic.fill" ? .white : Color("mainOrange")
    }

    var body: some View {
        ZStack {
            LearningNoteView()
                .offset(y: showNote ? 0 : UIScreen.main.bounds.height)
                .animation(.easeInOut, value: showNote)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if abs(value.translation.height) > abs(value.translation.width),
                               value.translation.height > 80 {
                                withAnimation {
                                    showNote = false
                                }
                            }
                        }
                )
                .zIndex(0)

            VStack {
                Spacer()
                ZStack {
                    recordingAnimation
                    
                    if lastRecordedURL != nil {
                            Capsule()
                                .fill(Color.white)
                                .frame(width: 370, height: 130)
                                .shadow(
                                    color: Color(red: 230 / 255, green: 237 / 255, blue: 241 / 255).opacity(1.0),
                                    radius: 20,
                                    x: 0,
                                    y: 15
                                )
                                .overlay(
                                    HStack {
                                        Image(systemName: "trash")
                                            .font(.system(size: 20))
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 32)
                                        
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .padding(.trailing, 32)
                                    }
                                )
                                .padding(.horizontal, 20)
                                .offset(y: 0)
                                .zIndex(0)
                        }

                    Circle()
                        .fill(buttonColor)
                        .frame(width: 185, height: 185)
                        .overlay(
                            Image(systemName: symbolName)
                                .foregroundColor(.black)
                                .font(.system(size: 40))
                        )
                        .shadow(
                            color: symbolName == "mic.fill"
                                ? Color(red: 230 / 255, green: 237 / 255, blue: 241 / 255).opacity(1.0)
                                : .clear,
                            radius: symbolName == "mic.fill" ? 20 : 0,
                            x: 0,
                            y: symbolName == "mic.fill" ? 15 : 0
                        )
                        .offset(x: dragOffset)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if abs(value.translation.width) < 10 {
                                        if !isPressing && !recorder.isRecording && lastRecordedURL == nil {
                                            isPressing = true
                                            recorder.startRecording()
                                        }
                                    } else {
                                        guard lastRecordedURL != nil else { return }
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if recorder.isRecording {
                                        recorder.stopRecording()
                                    }
                                    isPressing = false
                                    guard let url = lastRecordedURL else { return }
                                    let threshold: CGFloat = 100
                                    if value.translation.width < -threshold {
                                        lastRecordedURL = nil
                                    } else if value.translation.width > threshold {
                                        Task {
                                            await viewModel.sendQuestion(from: url)
                                            lastRecordedURL = nil
                                        }
                                    }
                                    withAnimation {
                                        dragOffset = .zero
                                    }
                                }
                        )
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded {
                                    if let url = lastRecordedURL, !recorder.isRecording {
                                        audioPlayer.playAudioWithHaptic(from: url)
                                    }
                                }
                        )
                }
                Spacer()
                EKOToggleIndicator(type: .downDirection)
                    .padding(.bottom, 24)
            }
            .offset(y: showNote ? -UIScreen.main.bounds.height : 0)
            .animation(.easeInOut, value: showNote)
            .zIndex(1)

            // 학습 노트로 전환하는 상단 스와이프 제스처
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .simultaneousGesture(
                    DragGesture()
                        .onEnded { value in
                            if abs(value.translation.height) > abs(value.translation.width),
                               value.translation.height < -80 {
                                withAnimation {
                                    showNote = true
                                }
                            }
                        }
                )
                .zIndex(0)
        }
        .onAppear {
            recorder.onRecordingFinished = { url in
                lastRecordedURL = url
            }
        }
        .onChange(of: isPressing) { isNowPressing in
            if isNowPressing && !recorder.isRecording && lastRecordedURL == nil {
                recorder.startRecording()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RecordingRequestView()
}
