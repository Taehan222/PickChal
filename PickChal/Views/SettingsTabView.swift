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

                    // MARK: - 프로필
                    if let user = user {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Profile")
                                    .font(themeManager.currentTheme.font)
                                    .foregroundColor(themeManager.currentTheme.accentColor)

                                VStack(alignment: .leading, spacing: 8) {
                                    profileRow(title: "출생", value: "\(user.year)년생")
                                    profileRow(title: "MBTI", value: user.mbti.rawValue)
                                    profileRow(title: "우선순위", value: user.priority.rawValue)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("목표")
                                            .fontWeight(.semibold)
                                        Text(user.goal)
                                            .font(.subheadline)
                                            .foregroundColor(themeManager.currentTheme.accentColor)
                                    }
                                    .padding(.top, 6)
                                }
                                .padding()
                                .background(themeManager.currentTheme.backgroundColor)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - 테마 선택
                    Section(header: Text("테마 선택").font(.headline)) {
                        Picker("테마", selection: $themeManager.currentTheme) {
                            ForEach(AppThemeColor.allCases) { theme in
                                Text(theme.displayName).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
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

                        SettingsActionRow(title: "테스트 알림 보내기", icon: "paperplane.fill", color: .red) {
                            if let first = challenges.first {
                                NotificationManager.shared.scheduleImmediateTestNotification(for: first)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - 계정 관리
                    VStack(spacing: 12) {
                        SettingsActionRow(title: "유저 정보 초기화", icon: "trash.fill", color: .red) {
                            print("초기화 기능은 여기서 구현 가능")
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
                .font(themeManager.currentTheme.font)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.currentTheme.accentColor)
            Spacer()
            Text(value)
                .foregroundColor(themeManager.currentTheme.accentColor)
        }
    }
}

struct SettingsRowCard<Destination: View>: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let detail: String
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack {
                Text(title)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                Spacer()
                Text(detail)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                Image(systemName: "chevron.right")
                    .foregroundColor(themeManager.currentTheme.accentColor)
            }
            .padding()
            .background(themeManager.currentTheme.backgroundColor)
            .cornerRadius(12)
        }
    }
}

struct SettingsToggleRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(themeManager.currentTheme.accentColor)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(themeManager.currentTheme.backgroundColor)
        .cornerRadius(12)
    }
}

struct SettingsActionRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(color)
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            .padding()
            .background(themeManager.currentTheme.backgroundColor)
            .cornerRadius(12)
        }
    }
}
