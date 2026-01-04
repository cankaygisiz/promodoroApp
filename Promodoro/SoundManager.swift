import AVFoundation
import SwiftUI

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var synthesizer: AVSpeechSynthesizer?
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        #endif
    }
    
    // MARK: - Sound Effects using Tone Generation
    
    func playStartSound() {
        // Pleasant ascending tone for start
        playTone(frequencies: [523.25, 659.25, 783.99], duration: 0.15, delayBetween: 0.1)
    }
    
    func playPauseSound() {
        // Soft descending tone for pause
        playTone(frequencies: [523.25, 440.0], duration: 0.12, delayBetween: 0.08)
    }
    
    func playResetSound() {
        // Quick reset sound
        playTone(frequencies: [440.0, 349.23], duration: 0.1, delayBetween: 0.05)
    }
    
    func playCompleteSound() {
        // Celebratory completion sound
        playTone(frequencies: [523.25, 659.25, 783.99, 1046.50], duration: 0.2, delayBetween: 0.12)
    }
    
    func playSkipSound() {
        // Quick skip sound
        playTone(frequencies: [659.25, 783.99], duration: 0.08, delayBetween: 0.05)
    }
    
    func playTickSound() {
        // Subtle tick for last 5 seconds
        playTone(frequencies: [880.0], duration: 0.05, delayBetween: 0)
    }
    
    // MARK: - Tone Generation
    
    private func playTone(frequencies: [Double], duration: Double, delayBetween: Double) {
        Task {
            for (index, frequency) in frequencies.enumerated() {
                if index > 0 {
                    try? await Task.sleep(nanoseconds: UInt64(delayBetween * 1_000_000_000))
                }
                await generateAndPlayTone(frequency: frequency, duration: duration)
            }
        }
    }
    
    @MainActor
    private func generateAndPlayTone(frequency: Double, duration: Double) {
        let sampleRate: Double = 44100
        let samples = Int(sampleRate * duration)
        
        var audioData = [Float](repeating: 0, count: samples)
        
        // Generate sine wave with envelope
        for i in 0..<samples {
            let time = Double(i) / sampleRate
            let envelope = sin(Double.pi * time / duration) // Smooth envelope
            audioData[i] = Float(sin(2.0 * Double.pi * frequency * time) * envelope * 0.3)
        }
        
        // Create audio buffer
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(samples)) else { return }
        buffer.frameLength = AVAudioFrameCount(samples)
        
        let channelData = buffer.floatChannelData![0]
        for i in 0..<samples {
            channelData[i] = audioData[i]
        }
        
        // Play using AVAudioEngine
        playBuffer(buffer)
    }
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    
    private func playBuffer(_ buffer: AVAudioPCMBuffer) {
        if audioEngine == nil {
            audioEngine = AVAudioEngine()
            playerNode = AVAudioPlayerNode()
            
            guard let engine = audioEngine, let player = playerNode else { return }
            
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
            
            do {
                try engine.start()
            } catch {
                print("Failed to start audio engine: \(error)")
                return
            }
        }
        
        guard let player = playerNode else { return }
        
        if !player.isPlaying {
            player.play()
        }
        
        player.scheduleBuffer(buffer, completionHandler: nil)
    }
}

// MARK: - Haptic Feedback (iOS only)
#if os(iOS)
import UIKit

extension SoundManager {
    func playHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func playSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
#endif
