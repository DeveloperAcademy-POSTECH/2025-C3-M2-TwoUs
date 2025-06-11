//
//  RecordingResponseView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI
import Lottie

struct RecordingResponseView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = RecordingResponseViewModel()
    
    @StateObject private var recorder = AudioRecorder()
    @StateObject private var audioPlayer = AudioPlayer()

    @State private var lastRecordedURL: URL?
    @State private var dragOffset: CGFloat = .zero
    @State private var feedbackPlayed = false
    @State private var feedbackSubmitted = false
    @State private var showRecordingUI = false
    @State private var showToast: Bool = false
    @Binding var isPressing: Bool

    struct LottieView: UIViewRepresentable {
        let animationName: String
        let loopMode: LottieLoopMode

        func makeUIView(context: Context) -> some UIView {
            let animationView = LottieAnimationView(name: animationName)
            animationView.loopMode = loopMode
            animationView.play()
            animationView.animationSpeed = 0.7
            animationView.backgroundBehavior = .pauseAndRestore
            return animationView
        }

        func updateUIView(_ uiView: UIViewType, context: Context) {}
    }

    @ViewBuilder
    private func CircleActionButton(symbolName: String, color: Color, action: @escaping () -> Void) -> some View {
        Circle()
            .fill(color)
            .frame(width: 185, height: 185)
            .overlay(
                Group {
                    if symbolName == "restart" {
                        Image("play")
                            .resizable()
                            .renderingMode(.original)
                            .scaledToFit()
                            .frame(width: 60, height: 50)
                            .offset(x: 5)
                    } else {
                        Image(systemName: symbolName)
                            .foregroundColor(.black)
                            .font(.system(size: 40))
                    }
                }
            )
            .shadow(
                color: symbolName == "mic.fill"
                ? Color(red: 230 / 255, green: 237 / 255, blue: 241 / 255).opacity(1.0)
                : .clear,
                radius: symbolName == "mic.fill" ? 20 : 0,
                x: 0,
                y: symbolName == "mic.fill" ? 15 : 0
            )
            .onTapGesture {
                action()
            }
    }

    @ViewBuilder
    private var recordingAnimation: some View {
        if recorder.isRecording {
            LottieView(animationName: "CircleWaveBlue", loopMode: .loop)
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
        symbolName == "mic.fill" ? .white : Color("mainBlue")
    }

    var body: some View {
        ZStack {
            VStack {
                FetchMyRequsetSubView(
                        friends: $viewModel.friends,
                        selectedRequestUserId: $viewModel.selectedRequestUserId
                    )
                    .padding(.leading, 20)
                    .padding(.bottom, 155)
                    .onAppear {
                          Task {
                              await viewModel.fetchMyRequestList()
                          }
                      }
                if viewModel.elapsedSeconds > 0 && !feedbackSubmitted {
                        RecordingTimerView(
                            time: viewModel.elapsedSeconds,
                            color: Color("mainBlue")
                        )
                    }
                
                if recorder.isRecording || audioPlayer.isPlaying || lastRecordedURL != nil {
                    RecordingTimerView(
                        time: viewModel.elapsedSeconds,
                        color: Color("mainBlue")
                    )
                }
                
                if feedbackSubmitted {
                    EKOEmptyView(title:"아직 받은 질문이 없습니다.", description: "친구가 발음을 보내면 피드백을 해줄 수 있어요.")
                } else if showRecordingUI {
                    VStack {
                        FetchMyRequsetSubView(
                            friends: $viewModel.friends,
                            selectedRequestUserId: $viewModel.selectedRequestUserId
                        )
                        .padding(.top)
                        
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
                                    Group {
                                        if recorder.isRecording || symbolName == "mic.fill" {
                                            Image("mic_blue")
                                                .resizable()
                                                .renderingMode(.original)
                                                .scaledToFit()
                                                .frame(width: 120, height: 120)
                                        } else if symbolName == "restart" {
                                            Image("play")
                                                .resizable()
                                                .renderingMode(.original)
                                                .scaledToFit()
                                                .frame(width: 60, height: 50)
                                                .offset(x: 5, y: 0)
                                        } else {
                                            Image(systemName: symbolName)
                                                .foregroundColor(.black)
                                                .font(.system(size: 40))
                                        }
                                    }
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
                                                    viewModel.startTimer()
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
                                                    await viewModel.sendFeedback(status: "Bad", fileURL: url)
                                                    lastRecordedURL = nil
                                                    feedbackSubmitted = true
                                                    showRecordingUI = false

                                                    showToast = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                        showToast = false
                                                    }
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
                                                audioPlayer.playAudioWithHaptic(from: url, noteId: nil, voiceType: .none)
                                                viewModel.startTimer()
                                                
                                                audioPlayer.onFinishPlaying = {
                                                    viewModel.stopTimer()
                                                }
                                            }
                                        }
                                )
                        }
                        .padding()
                        
                    }
                } else {
                    CircleActionButton(symbolName: "restart", color: Color("mainBlue")) {
                        Task {
                            viewModel.elapsedSeconds = 0
                            await viewModel.playFeedback(using: audioPlayer)
                            feedbackPlayed = true
                            viewModel.startTimer()
                            audioPlayer.onFinishPlaying = {
                                viewModel.stopTimer()
                            }
                        }
                    }
                    .padding()

                    if feedbackPlayed {
                        HStack(spacing: 20) {
                            Button(action: {
                                Task {
                                    await viewModel.sendFeedback(status: "Good", fileURL: nil)
                                    feedbackSubmitted = true
                                    feedbackPlayed = false
                                }
                            }) {
                                Image(systemName: "hand.thumbsup.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color("mainBlue"))
                                    .padding(24)
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                            )
                                    )
                            }

                            Button(action: {
                                showRecordingUI = true
                            }) {
                                Text("내 발음 들려주기")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color("mainBlue"))
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 40)
                                            .fill(Color.white)
                                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 40)
                                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .padding()
                    }
                }
            }

            VStack {
                Spacer()
                if !feedbackSubmitted {
                            if showRecordingUI {
                                if lastRecordedURL != nil {
                                    EKONoticeText(title: "음성을 확인한 뒤 좌우로 스와이프 해주세요.")
                                        .padding(.bottom, 120)
                                } else {
                                    EKONoticeText(title: "길게 눌러 들은 문장을 그대로 따라 읽기")
                                        .padding(.bottom, 120)
                                }
                            } else if !feedbackPlayed {
                                EKONoticeText(title: "발음 듣고 피드백 보내기")
                                    .padding(.bottom, 120)
                            }
                        }
                if showToast {
                    EKOToastMessage(toastType: .completeAnswer)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showToast)
                        .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            recorder.onRecordingFinished = { url in
                lastRecordedURL = url
                viewModel.stopTimer()
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
    RecordingResponseView(isPressing: .constant(false))
}
