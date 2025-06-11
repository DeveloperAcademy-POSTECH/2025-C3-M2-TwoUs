
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

    private var shouldShowTimer: Bool {
        (recorder.isRecording || audioPlayer.isPlaying || lastRecordedURL != nil) && !feedbackSubmitted
    }

    var body: some View {
        ZStack {
            VStack {
                FetchMyRequsetSubView(
                    friends: $viewModel.friends,
                    selectedRequestUserId: $viewModel.selectedRequestUserId,
                    onFriendSelected: { _ in
                        Task {
                            await viewModel.fetchFeedbackS3Key()
                        }
                    }
                )
                .padding(.leading, 20)
                .padding(.bottom, 155)

                RecordingTimerView(
                    time: viewModel.elapsedSeconds,
                    color: Color("mainBlue")
                )
                .opacity(shouldShowTimer ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: shouldShowTimer)

                Spacer()
            }

            VStack {
                Spacer()

                if !viewModel.hasSession {
                    EKOEmptyView(title: "아직 받은 질문이 없습니다.", description: "친구가 발음을 보내면 피드백을 해줄 수 있어요.")
                } else if feedbackSubmitted {
                    EKOEmptyView(title: "요청 완료", description: "다른 요청을 확인해보세요.")
                } else if showRecordingUI {
                    RecordingPanelView(
                        isPressing: $isPressing,
                        lastRecordedURL: $lastRecordedURL,
                        dragOffset: $dragOffset,
                        feedbackSubmitted: $feedbackSubmitted,
                        showToast: $showToast,
                        showRecordingUI: $showRecordingUI,
                        recorder: recorder,
                        audioPlayer: audioPlayer,
                        onSendFeedback: { url in
                            await viewModel.sendFeedback(status: "Bad", fileURL: url)
                        },
                        onStopRecording: {
                            viewModel.stopTimer()
                        },
                        onStartTimer: {
                            viewModel.startTimer()
                        },
                        onStopTimer: {
                            viewModel.stopTimer()
                        }
                    )
                } else {
                    VStack {
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

                            PronunciationFeedbackButton {
                                showRecordingUI = true
                            }
                        }
                        .opacity(feedbackPlayed ? 1 : 0)
                        .animation(.easeInOut, value: feedbackPlayed)
                    }
                }

                Spacer()
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
            Task {
                await viewModel.fetchMyRequestList()
            }

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
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: .feedbackSendedReceived, object: nil)
        }
        .onChange(of: isPressing) { isNowPressing in
            if isNowPressing && !recorder.isRecording && lastRecordedURL == nil {
                recorder.startRecording()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func CircleActionButton(symbolName: String, color: Color, action: @escaping () -> Void) -> some View {
        Circle()
            .fill(color)
            .frame(width: 185, height: 185)
            .overlay(
                Image("play")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .scaledToFit()
                    .frame(width: 60, height: 50)
                    .offset(x: 5)
            )
            .shadow(
                color: Color(red: 230 / 255, green: 237 / 255, blue: 241 / 255).opacity(1.0),
                radius: 20, x: 0, y: 15
            )
            .onTapGesture {
                action()
            }
    }
}

extension Notification.Name {
    static let feedbackSendedReceived = Notification.Name("feedbackSendedReceived")
}
