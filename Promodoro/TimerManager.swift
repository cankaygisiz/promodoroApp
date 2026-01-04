import Foundation
import SwiftUI
import Combine
import UserNotifications

enum TimerMode: String, CaseIterable {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    
    var defaultDuration: TimeInterval {
        switch self {
        case .focus: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }
    
    var color: Color {
        switch self {
        case .focus: return AppTheme.orange
        case .shortBreak, .longBreak: return AppTheme.cyan
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .focus: return AppTheme.orangeGradient
        case .shortBreak, .longBreak: return AppTheme.cyanGradient
        }
    }
}

enum TimerState {
    case idle
    case running
    case paused
}

class TimerManager: ObservableObject {
    @Published var mode: TimerMode = .focus
    @Published var state: TimerState = .idle
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var completedPomodoros: Int = 0
    
    // Settings
    @Published var focusDuration: TimeInterval = 25 * 60
    @Published var shortBreakDuration: TimeInterval = 5 * 60
    @Published var longBreakDuration: TimeInterval = 15 * 60
    @Published var pomodorosUntilLongBreak: Int = 4
    @Published var autoStartBreaks: Bool = false
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        resetTimer()
    }
    
    var progress: Double {
        let totalDuration = currentDuration
        guard totalDuration > 0 else { return 0 }
        return 1 - (timeRemaining / totalDuration)
    }
    
    var currentDuration: TimeInterval {
        switch mode {
        case .focus: return focusDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func start() {
        state = .running
        SoundManager.shared.playStartSound()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        state = .paused
        SoundManager.shared.playPauseSound()
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        state = .idle
        SoundManager.shared.playResetSound()
        timer?.invalidate()
        timer = nil
        resetTimer()
    }
    
    func skip() {
        SoundManager.shared.playSkipSound()
        timer?.invalidate()
        timer = nil
        completeCurrentSession()
    }
    
    func setMode(_ newMode: TimerMode) {
        timer?.invalidate()
        timer = nil
        state = .idle
        mode = newMode
        resetTimer()
    }
    
    func resetProgress() {
        completedPomodoros = 0
    }
    
    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            // Play tick sound for last 5 seconds
            if timeRemaining <= 5 && timeRemaining > 0 {
                SoundManager.shared.playTickSound()
            }
        } else {
            SoundManager.shared.playCompleteSound()
            completeCurrentSession()
        }
    }
    
    private func completeCurrentSession() {
        timer?.invalidate()
        timer = nil
        
        #if os(macOS)
        sendNotification()
        #endif
        
        #if os(iOS)
        sendNotification()
        #endif
        
        if mode == .focus {
            completedPomodoros += 1
            
            // Determine next break type
            if completedPomodoros % pomodorosUntilLongBreak == 0 {
                mode = .longBreak
            } else {
                mode = .shortBreak
            }
        } else {
            mode = .focus
        }
        
        state = .idle
        resetTimer()
        
        // Auto-start next session if enabled
        if autoStartBreaks {
            start()
        }
    }
    
    private func resetTimer() {
        timeRemaining = currentDuration
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Timer"
        
        switch mode {
        case .focus:
            content.body = "Great work! Time for a break."
        case .shortBreak, .longBreak:
            content.body = "Break's over! Ready to focus?"
        }
        
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    private func loadSettings() {
        if let focus = UserDefaults.standard.object(forKey: "focusDuration") as? TimeInterval {
            focusDuration = focus
        }
        if let shortBreak = UserDefaults.standard.object(forKey: "shortBreakDuration") as? TimeInterval {
            shortBreakDuration = shortBreak
        }
        if let longBreak = UserDefaults.standard.object(forKey: "longBreakDuration") as? TimeInterval {
            longBreakDuration = longBreak
        }
        if let count = UserDefaults.standard.object(forKey: "pomodorosUntilLongBreak") as? Int {
            pomodorosUntilLongBreak = count
        }
        autoStartBreaks = UserDefaults.standard.bool(forKey: "autoStartBreaks")
    }
    
    func saveSettings() {
        UserDefaults.standard.set(focusDuration, forKey: "focusDuration")
        UserDefaults.standard.set(shortBreakDuration, forKey: "shortBreakDuration")
        UserDefaults.standard.set(longBreakDuration, forKey: "longBreakDuration")
        UserDefaults.standard.set(pomodorosUntilLongBreak, forKey: "pomodorosUntilLongBreak")
        UserDefaults.standard.set(autoStartBreaks, forKey: "autoStartBreaks")
    }
}
