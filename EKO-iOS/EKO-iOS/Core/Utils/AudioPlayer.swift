//
//  AudioPlayer.swift
//  EKO-iOS
//
//  Created by Seungeun Park on 5/28/25.
//

import Foundation
import AVFoundation
import CoreHaptics

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var engine: CHHapticEngine?

    override init() {
        super.init()
        prepareHaptics()
    }

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("햅틱 엔진 시작 실패: \(error)")
        }
    }

    func playAudioWithHaptic(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.isMeteringEnabled = true
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            startMonitoring()
        } catch {
            print("오디오 재생 실패: \(error)")
        }
    }

    private func startMonitoring() {
        stopMonitoring()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = self.audioPlayer, player.isPlaying else { return }
            player.updateMeters()
            let db = player.averagePower(forChannel: 0)
            self.triggerHaptic(for: db)
        }
    }

    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopMonitoring()
        print("오디오 재생 종료")
    }

    private func triggerHaptic(for db: Float) {
        guard let engine = engine else { return }
        guard db > -20 else { return }

        let intensity = max(0, min(1, (db + 80) / 80))
        let sharpness: Float = 0.5

        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)

        let event = CHHapticEvent(eventType: .hapticContinuous,
                                  parameters: [intensityParam, sharpnessParam],
                                  relativeTime: 0,
                                  duration: 0.1)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("햅틱 재생 실패: \(error)")
        }
    }
}
