import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerManager: TimerManager
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HeaderView(showSettings: $showSettings)
                
                Spacer()
                
                // Timer Circle
                TimerCircleView()
                
                // Mode Selector
                ModeSelectorView()
                
                Spacer()
                
                // Control Buttons
                ControlButtonsView()
                
                // Completed Pomodoros
                CompletedPomodorosView()
            }
            .padding()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            timerManager.requestNotificationPermission()
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
            Text("Promodoro")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Timer Circle View
struct TimerCircleView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(
                    timerManager.mode.color.opacity(0.2),
                    lineWidth: 12
                )
            
            // Progress Circle
            Circle()
                .trim(from: 0, to: timerManager.progress)
                .stroke(
                    timerManager.mode.gradient,
                    style: StrokeStyle(
                        lineWidth: 12,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: timerManager.progress)
            
            // Inner content
            VStack(spacing: 8) {
                Text(timerManager.mode.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(timerManager.mode.color)
                
                Text(timerManager.formattedTime)
                    .font(.system(size: 56, weight: .light, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                    .monospacedDigit()
            }
        }
        .frame(width: 250, height: 250)
    }
}

// MARK: - Mode Selector View
struct ModeSelectorView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(TimerMode.allCases, id: \.self) { mode in
                ModeButton(
                    mode: mode,
                    isSelected: timerManager.mode == mode
                ) {
                    timerManager.setMode(mode)
                }
            }
        }
    }
}

struct ModeButton: View {
    let mode: TimerMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(mode.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? AppTheme.backgroundDark : AppTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? mode.color : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(mode.color.opacity(0.5), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Control Buttons View
struct ControlButtonsView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 20) {
            // Reset Button
            Button(action: { timerManager.reset() }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(AppTheme.backgroundLight)
                    )
            }
            .buttonStyle(.plain)
            
            // Play/Pause Button
            Button(action: {
                if timerManager.state == .running {
                    timerManager.pause()
                } else {
                    timerManager.start()
                }
            }) {
                Image(systemName: timerManager.state == .running ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundColor(AppTheme.backgroundDark)
                    .frame(width: 70, height: 70)
                    .background(
                        Circle()
                            .fill(timerManager.mode.gradient)
                    )
                    .shadow(color: timerManager.mode.color.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
            
            // Skip Button
            Button(action: { timerManager.skip() }) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(AppTheme.backgroundLight)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Completed Pomodoros View
struct CompletedPomodorosView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<timerManager.pomodorosUntilLongBreak, id: \.self) { index in
                Circle()
                    .fill(index < timerManager.completedPomodoros % timerManager.pomodorosUntilLongBreak || 
                          (timerManager.completedPomodoros > 0 && timerManager.completedPomodoros % timerManager.pomodorosUntilLongBreak == 0 && index == 0) 
                          ? AppTheme.orange : AppTheme.orange.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
            
            Text("\(timerManager.completedPomodoros) completed")
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
                .padding(.leading, 8)
            
            if timerManager.completedPomodoros > 0 {
                Button(action: { timerManager.resetProgress() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary.opacity(0.6))
                }
                .buttonStyle(.plain)
                .help("Reset progress")
            }
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerManager())
}
