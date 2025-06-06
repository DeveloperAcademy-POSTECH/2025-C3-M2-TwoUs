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
    @State private var isPressing = false
    @State private var dragOffset: CGFloat = .zero
    @State private var feedbackPlayed = false
    @State private var feedbackSubmitted = false
    @State private var showRecordingUI = false
    
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
        VStack {
            if feedbackSubmitted {
            } else if showRecordingUI {
                ZStack {
                    recordingAnimation
                    
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
                                            await viewModel.sendFeedback(status: "Bad", fileURL: url)
                                            lastRecordedURL = nil
                                            feedbackSubmitted = true
                                            showRecordingUI = false
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
                .padding()
            } else {
                CircleActionButton(symbolName: "restart", color: Color("mainBlue")) {
                    Task {
                        await viewModel.playFeedback(using: audioPlayer)
                        feedbackPlayed = true
                    }
                }
                .padding()
                .buttonStyle(.borderedProminent)
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

                          // 내 발음 들려주기 버튼 커스텀
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
        .onAppear {
            recorder.onRecordingFinished = { url in
                print("녹음 완료 파일 URL:", url)
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
    RecordingResponseView()
}
