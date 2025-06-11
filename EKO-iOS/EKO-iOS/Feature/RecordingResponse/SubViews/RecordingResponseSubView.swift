//
//  RecordingResponseSubView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI
import Lottie

struct FetchMyRequsetSubView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    @Binding var friends: [RecordingResponseViewModel.EKORequestFriend]
    @Binding var selectedRequestUserId: String?
    
    let type: EKOFriendsViewType = .response
    var onFriendSelected: (RecordingResponseViewModel.EKORequestFriend) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(friends) { friend in
                    EKOFriendsView(
                        type: type,
                        name: friend.senderNickname,
                        isSelected: selectedRequestUserId == friend.senderUserId
                    )
                    .padding(.vertical, 10)
                    .padding(.horizontal, 2)
                    .onTapGesture {
                        if selectedRequestUserId != friend.senderUserId {
                            selectedRequestUserId = friend.senderUserId
                            onFriendSelected(friend)
                        }
                    }
                }
            }
        }
    }
}

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

struct RecordingPanelView: View {
    @Binding var isPressing: Bool
    @Binding var lastRecordedURL: URL?
    @Binding var dragOffset: CGFloat
    @Binding var feedbackSubmitted: Bool
    @Binding var showToast: Bool
    @Binding var showRecordingUI: Bool

    let recorder: AudioRecorder
    let audioPlayer: AudioPlayer
    let onSendFeedback: (URL) async -> Void
    let onStopRecording: () -> Void
    let onStartTimer: () -> Void
    let onStopTimer: () -> Void

    var body: some View {
        VStack {
            ZStack {
                if recorder.isRecording {
                    LottieView(animationName: "CircleWaveBlue", loopMode: .loop)
                        .frame(width: 300, height: 300)
                }

                if lastRecordedURL != nil {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 370, height: 130)
                        .shadow(
                            color: Color(red: 230 / 255, green: 237 / 255, blue: 241 / 255).opacity(1.0),
                            radius: 20, x: 0, y: 15
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
                    .fill(recorder.isRecording ? Color("mainBlue") : .white)
                    .frame(width: 185, height: 185)
                    .overlay(
                        Group {
                            if recorder.isRecording {
                                Image("mic_blue")
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                            } else if lastRecordedURL != nil {
                                Image("play")
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 60, height: 50)
                                    .offset(x: 5)
                            } else {
                                Image("mic_blue")
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                            }
                        }
                    )
                    .shadow(
                        color: Color(red: 230 / 255, green: 237 / 255, blue: 241 / 255).opacity(1.0),
                        radius: 20, x: 0, y: 15
                    )
                    .offset(x: dragOffset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if abs(value.translation.width) < 10 {
                                    if !isPressing && !recorder.isRecording && lastRecordedURL == nil {
                                        isPressing = true
                                        recorder.startRecording()
                                        onStartTimer()
                                    }
                                } else {
                                    guard lastRecordedURL != nil else { return }
                                    dragOffset = value.translation.width
                                }
                            }
                            .onEnded { value in
                                if recorder.isRecording {
                                    recorder.stopRecording()
                                    onStopRecording()
                                }
                                isPressing = false

                                guard let url = lastRecordedURL else { return }

                                let threshold: CGFloat = 100
                                if value.translation.width < -threshold {
                                    lastRecordedURL = nil
                                } else if value.translation.width > threshold {
                                    Task {
                                        await onSendFeedback(url)
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
                                    onStartTimer()
                                    audioPlayer.onFinishPlaying = {
                                        onStopTimer()
                                    }
                                }
                            }
                    )
            }
            Spacer()
        }
    }
}

struct PronunciationFeedbackButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
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
}
