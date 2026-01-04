import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var timerManager: TimerManager
    @Environment(\.dismiss) var dismiss
    
    @State private var focusMinutes: Double = 25
    @State private var shortBreakMinutes: Double = 5
    @State private var longBreakMinutes: Double = 15
    @State private var pomodorosCount: Double = 4
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Timer Settings
                        SettingsSection(title: "Timer Durations") {
                            SettingsSlider(
                                title: "Focus",
                                value: $focusMinutes,
                                range: 1...60,
                                unit: "min",
                                color: AppTheme.orange
                            )
                            
                            SettingsSlider(
                                title: "Short Break",
                                value: $shortBreakMinutes,
                                range: 1...30,
                                unit: "min",
                                color: AppTheme.cyan
                            )
                            
                            SettingsSlider(
                                title: "Long Break",
                                value: $longBreakMinutes,
                                range: 1...60,
                                unit: "min",
                                color: AppTheme.cyan
                            )
                        }
                        
                        // Session Settings
                        SettingsSection(title: "Sessions") {
                            SettingsSlider(
                                title: "Pomodoros until long break",
                                value: $pomodorosCount,
                                range: 2...8,
                                unit: "",
                                color: AppTheme.orange
                            )
                        }
                        
                        // About Section
                        SettingsSection(title: "About") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Promodoro Timer")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Text("A beautiful Pomodoro timer app to help you stay focused and productive.")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                HStack(spacing: 16) {
                                    Label("Focus", systemImage: "flame.fill")
                                        .foregroundColor(AppTheme.orange)
                                    
                                    Label("Rest", systemImage: "leaf.fill")
                                        .foregroundColor(AppTheme.cyan)
                                }
                                .font(.caption)
                                .padding(.top, 8)
                            }
                            .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                    .foregroundColor(AppTheme.cyan)
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 500)
        #endif
    }
    
    private func loadCurrentSettings() {
        focusMinutes = timerManager.focusDuration / 60
        shortBreakMinutes = timerManager.shortBreakDuration / 60
        longBreakMinutes = timerManager.longBreakDuration / 60
        pomodorosCount = Double(timerManager.pomodorosUntilLongBreak)
    }
    
    private func saveSettings() {
        timerManager.focusDuration = focusMinutes * 60
        timerManager.shortBreakDuration = shortBreakMinutes * 60
        timerManager.longBreakDuration = longBreakMinutes * 60
        timerManager.pomodorosUntilLongBreak = Int(pomodorosCount)
        timerManager.saveSettings()
        timerManager.reset()
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textSecondary)
                .textCase(.uppercase)
            
            VStack(spacing: 16) {
                content
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.backgroundLight)
            )
        }
    }
}

// MARK: - Settings Slider
struct SettingsSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("\(Int(value))\(unit.isEmpty ? "" : " \(unit)")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            Slider(value: $value, in: range, step: 1)
                .tint(color)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(TimerManager())
}
