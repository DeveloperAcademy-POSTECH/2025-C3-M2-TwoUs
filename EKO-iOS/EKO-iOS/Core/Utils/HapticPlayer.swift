//
//  HapticPlayer.swift
//  EKO-iOS
//
//  Created by Seungeun Park on 5/28/25.
//

import Foundation
import AVFoundation
import CoreHaptics

class HapticPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var engine: CHHapticEngine?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?

    func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("햅틱 엔진 시작 실패: \(error)")
        }
    }

    func playAudioWithHaptics(named fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "m4a") else {
            print("오디오 파일 \(fileName).m4a 를 찾을 수 없습니다.")
            return
        }

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
            self.audioPlayer?.updateMeters()
            let db = self.audioPlayer?.averagePower(forChannel: 0) ?? -100
            self.playHapticByDB(db)
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

    private func playHaptic(intensity: Float, sharpness: Float, duration: TimeInterval, eventType: CHHapticEvent.EventType) {
        guard let engine = engine else { return }

        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)

        let event = CHHapticEvent(eventType: eventType,
                                  parameters: [intensityParam, sharpnessParam],
                                  relativeTime: 0,
                                  duration: duration)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("진동 재생 실패: \(error)")
        }
    }

    // 이건 이름 바꿔야하는데 얼른 ㅋㅋ ..
    func playPresetHaptic(type: Int) {
        switch type {
        case 1:
            playHaptic(intensity: 0.3, sharpness: 0.8, duration: 0.0, eventType: .hapticTransient)
        case 2:
            playHaptic(intensity: 0.5, sharpness: 0.5, duration: 0.1, eventType: .hapticContinuous)
        case 3:
            playHaptic(intensity: 0.7, sharpness: 0.2, duration: 0.2, eventType: .hapticContinuous)
        case 4:
            playHaptic(intensity: 1.0, sharpness: 1.0, duration: 0.2, eventType: .hapticContinuous)
        default:
            return
        }
    }

    private func playHapticByDB(_ db: Float) {
        guard let engine = engine else { return }
        guard db > -20 else { return }

        let intensity: Float
        let sharpness: Float
        let duration: TimeInterval
        let eventType: CHHapticEvent.EventType
        
        // 햅틱 종류를 변경하면 햅틱이 좀 더 와닿을까 .. . .. . . 🥹
        switch db {
        case -20...(-15):
            intensity = 0.3
            sharpness = 0.8
            duration = 0.0
            eventType = .hapticTransient
        case -15...(-10):
            intensity = 0.5
            sharpness = 0.5
            duration = 0.1
            eventType = .hapticContinuous
        case -10...(-5):
            intensity = 0.7
            sharpness = 0.2
            duration = 0.2
            eventType = .hapticContinuous
        case -5...0:
            intensity = 1.0
            sharpness = 1.0
            duration = 0.2
            eventType = .hapticContinuous
        default:
            return
        }

        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)

        let event = CHHapticEvent(eventType: eventType,
                                  parameters: [intensityParam, sharpnessParam],
                                  relativeTime: 0,
                                  duration: duration)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("햅틱 재생 실패: \(error)")
        }
    }
}

