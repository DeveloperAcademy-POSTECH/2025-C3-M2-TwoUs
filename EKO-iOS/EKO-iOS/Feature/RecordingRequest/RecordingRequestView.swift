//
//  RecordingRequestView.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

struct RecordingRequestView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = RecordingRequestViewModel()
    
    @StateObject private var recorder = AudioRecorder()
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var isPlaying = false
    @State private var animatePulse = false
    @State private var lastRecordedURL: URL?
    
    var body: some View {
        VStack(spacing: 30) {
            
            ZStack {
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
                        .fill(recorder.isRecording ? Color.red : Color.blue)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                        )
                }
            }
            
            if let url = lastRecordedURL {
                Button(action: {
                    isPlaying = true
                    audioPlayer.playAudioWithHaptic(from: url)
                }) {
                    Text("듣기")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .onAppear {
            recorder.onRecordingFinished = { url in
                print("녹음 완료 파일 URL:", url)
                lastRecordedURL = url
                
                Task {
                    await viewModel.sendQuestion(from: url)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.05))
    }
}

#Preview {
    RecordingRequestView()
}

