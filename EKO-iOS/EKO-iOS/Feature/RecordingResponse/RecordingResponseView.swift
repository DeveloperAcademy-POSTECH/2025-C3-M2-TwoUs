//
//  RecordingResponseView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

struct RecordingResponseView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    
    @StateObject private var viewModel = RecordingResponseViewModel()
    @StateObject private var recorder = AudioRecorder()
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var lastRecordedURL: URL?
    @State private var animatePulse = false
    
    var body: some View {
        VStack(spacing: 30) {
            Button("피드백 듣기") {
                Task {
                    await viewModel.playFeedback(using: audioPlayer)
                }
            }

            Button("피드백 전송_Good") {
                Task {
                    await viewModel.sendFeedback(status: "Good", fileURL: nil)
                }
            }

            Button(action: {
                if recorder.isRecording {
                    recorder.stopRecording()
                    animatePulse = false
                } else {
                    recorder.startRecording()
                    animatePulse = true
                }
            }) {
                Circle()
                    .fill(recorder.isRecording ? Color.red : Color.orange)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                    )
            }

            if let url = lastRecordedURL {
                Button("피드백 전송_Bad") {
                    Task {
                        await viewModel.sendFeedback(status: "Bad", fileURL: url)
                    }
                }
            }
        }
        .onAppear {
            recorder.onRecordingFinished = { url in
                print("피드백 녹음 완료:", url)
                lastRecordedURL = url
            }
        }
        .padding()
//        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    RecordingResponseView()
}

