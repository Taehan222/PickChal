import SwiftUI
import Charts

struct SettingsTabView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @EnvironmentObject var statsVM: StatisticsViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var challenges: [ChallengeModel] {
        statsVM.challengeModels
    }

    var user: UserModel? {
        statsVM.user
    }

    var completedChallenges: [ChallengeModel] {
        challenges.filter { $0.isCompleted }
    }

    var ongoingChallenges: [ChallengeModel] {
        challenges.filter { !$0.isCompleted }
    }

    var challengeCompletionRate: Int {
        let total = challenges.count
        guard total > 0 else { return 0 }
        let completed = completedChallenges.count
        return Int((Double(completed) / Double(total)) * 100)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: - 테마 선택
                    SettingsCard {
                        VStack(alignment: .leading) {
                            Text("테마 선택")
                                .font(.headline)
                                .foregroundColor(.black)
                            Picker("테마", selection: $themeManager.currentTheme) {
                                ForEach(AppTheme.allCases) { theme in
                                    Text(theme.displayName).tag(theme)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - 챌린지 통계
                    VStack(spacing: 12) {
                        SettingsRowCard(title: "챌린지 통계", detail: "\(challengeCompletionRate)%") {
                            ChallengeStatsDetailView(challenges: challenges)
                        }

                        SettingsRowCard(title: "완료한 챌린지", detail: "\(completedChallenges.count)개") {
                            ChallengeCompletedListView(completed: completedChallenges)
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - 알림 설정
                    VStack(spacing: 12) {
                        SettingsToggleRow(title: "알림 설정", isOn: $notificationsEnabled)
                            .onChange(of: notificationsEnabled) { isOn in
                                if isOn {
                                    for challenge in ongoingChallenges {
                                        NotificationManager.shared.scheduleChallenge(challenge)
                                    }
                                } else {
                                    NotificationManager.shared.removeAll()
                                }
                            }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 48)
                }
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                statsVM.loadStatistics()
                statsVM.loadUserProfile()
            }
        }
    }

    func profileRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            Spacer()
            Text(value)
                .foregroundColor(.black)
        }
    }
}

struct SettingsCard<Content: View>: View {
    @EnvironmentObject var themeManager: ThemeManager
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.currentTheme.accentColor, lineWidth: 1.5)
            )
    }
}

struct SettingsRowCard<Destination: View>: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let detail: String
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            SettingsCard {
                HStack {
                    Text(title)
                        .foregroundColor(.black)
                    Spacer()
                    Text(detail)
                        .foregroundColor(.black)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        SettingsCard {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
        }
    }
}

struct SettingsActionRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SettingsCard {
                HStack {
                    Text(title)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: icon)
                        .foregroundColor(.black)
                }
            }
        }
    }
}
