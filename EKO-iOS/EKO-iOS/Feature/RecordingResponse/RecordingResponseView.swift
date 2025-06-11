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

    var body: some View {
        ZStack {
            VStack {
                FetchMyRequsetSubView(
                    friends: $viewModel.friends,
                    selectedRequestUserId: $viewModel.selectedRequestUserId,
                    onFriendSelected: { friend in
                        feedbackPlayed = false
                        feedbackSubmitted = false
                        showRecordingUI = false
                        lastRecordedURL = nil

                        Task {
                            await viewModel.fetchFeedbackS3Key()
                        }
                    }
                )
                .padding(.leading, 20)
                .padding(.bottom, 155)
                .opacity(recorder.isRecording ? 0 : 1)
                .animation(.easeInOut(duration: 0.01), value: recorder.isRecording)

                if !viewModel.hasSession {
                    EKOEmptyView(
                        title:"아직 받은 질문이 없습니다.",
                        description: "친구가 발음을 보내면 피드벡을 해줄 수 있어요."
                    )
                } else if feedbackSubmitted {
                    EKOEmptyView(title:"요청 완료", description: "다른 요청을 확인해보세요.")
                } else if showRecordingUI {
                    RecordingUI
                } else if feedbackPlayed {
                    FeedbackButtons
                } else {
                    PlayButton
                }
                Spacer()
            }
            if showToast {
                VStack {
                    Spacer()
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

            NotificationCenter.default.addObserver(forName: .feedbackSendedReceived, object: nil, queue: .main) { _ in
                Task {
                    await viewModel.fetchMyRequestList()
                }
            }
        }
        .onChange(of: feedbackSubmitted) { newValue in
            if newValue {
                Task {
                    await viewModel.fetchMyRequestList()
                    feedbackSubmitted = false
                }
            }
        }
    }

    private var PlayButton: some View {
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
    }

    private var FeedbackButtons: some View {
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
                    .background(Circle().fill(Color.white).shadow(radius: 6))
            }

            Button(action: {
                showRecordingUI = true
            }) {
                Text("내 발음 들려주기")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color("mainBlue"))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 40).fill(Color.white).shadow(radius: 6))
            }
        }
        .padding()
    }

    private var RecordingUI: some View {
        VStack {
            if recorder.isRecording {
                LottieView(animationName: "CircleWaveBlue", loopMode: .loop)
                    .frame(width: 300, height: 300)
            }
            CircleActionButton(symbolName: symbolName, color: buttonColor) {
                // Gesture 기반으로 변경
            }
            .gesture(RecordingGesture)
            Spacer()
        }
    }

    private var RecordingGesture: some Gesture {
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
}

extension Notification.Name {
    static let feedbackSendedReceived = Notification.Name("feedbackSendedReceived")
}

#Preview {
    RecordingResponseView(isPressing: .constant(false))
}
