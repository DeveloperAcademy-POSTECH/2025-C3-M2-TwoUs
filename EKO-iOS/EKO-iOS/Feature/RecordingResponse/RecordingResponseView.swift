
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
    @State private var feedbackSubmitted = false
    @State private var showRecordingUI = false
    @State private var showToast: Bool = false
    @State private var playbackStarted = false

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
                    onFriendSelected: { _ in
                        resetPlaybackState()
                        Task {
                            await viewModel.fetchFeedbackS3Key()
                        }
                    }
                )
                .padding(.leading, 20)
                .padding(.bottom, 155)

                if !viewModel.hasSession {
                    EKOEmptyView(title:"아직 받은 질문이 없습니다.", description: "친구가 발음을 보내면 피드백을 해줄 수 있어요.")
                } else if feedbackSubmitted {
                    EKOEmptyView(title:"요청 완료", description: "다른 요청을 확인해보세요.")
                } else {
                    VStack(spacing: 20) {
                        PlayButton
                        FeedbackButtons
                            .opacity(playbackStarted ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: playbackStarted)
                    }
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
                playbackStarted = true
                viewModel.startTimer()
                audioPlayer.onFinishPlaying = {
                    viewModel.stopTimer()
                    // Keep playbackStarted = true to maintain button
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
                    playbackStarted = false
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

    private func resetPlaybackState() {
        playbackStarted = false
        feedbackSubmitted = false
        showRecordingUI = false
        lastRecordedURL = nil
    }

    @ViewBuilder
    private func CircleActionButton(symbolName: String, color: Color, action: @escaping () -> Void) -> some View {
        Circle()
            .fill(color)
            .frame(width: 185, height: 185)
            .overlay(
                Image("play")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 60, height: 50)
                    .offset(x: 5)
            )
            .shadow(
                color: Color(red: 230 / 255, green: 237 / 255, blue: 241 / 255).opacity(1.0),
                radius: 20,
                x: 0,
                y: 15
            )
            .onTapGesture {
                action()
            }
    }
}

extension Notification.Name {
    static let feedbackSendedReceived = Notification.Name("feedbackSendedReceived")
}
