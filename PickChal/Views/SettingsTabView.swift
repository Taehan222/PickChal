import SwiftUI
import Charts

struct SettingsTabView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @EnvironmentObject var statsVM: StatisticsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedStat: ChallengeStatType = .completionRate

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

    var categorySummary: [String: Int] {
        Dictionary(grouping: challenges, by: { $0.category }).mapValues { $0.count }
    }

    var durationByChallenge: [(title: String, days: Int)] {
        challenges.map {
            let diff = Calendar.current.dateComponents([.day], from: $0.startDate, to: $0.endDate).day ?? 0
            return (title: $0.title, days: max(diff, 0))
        }
    }

    var weekdaySummary: [String: Int] {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let grouped = Dictionary(grouping: challenges) {
            let weekday = Calendar.current.component(.weekday, from: $0.startDate)
            return weekdays[weekday - 1]
        }
        return grouped.mapValues { $0.count }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: - 챌린지 통계 요약
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("챌린지 통계")
                                .font(.headline)
                                .foregroundColor(Color.primary)

                            Picker("통계 유형", selection: $selectedStat) {
                                ForEach(ChallengeStatType.allCases) { stat in
                                    Text(stat.rawValue).tag(stat)
                                }
                            }
                            .pickerStyle(.segmented)

                            Group {
                                switch selectedStat {
                                case .completionRate:
                                    completionChart
                                case .categoryDistribution:
                                    categoryChart
                                case .durationDistribution:
                                    durationChart
                                case .weekdayStart:
                                    weekdayChart
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - 테마 선택 (테두리만 칠해지는 커스텀 스타일)
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("테마 선택")
                                .font(.headline)
                                .foregroundColor(Color.primary)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 12) {
                                ForEach(AppTheme.allCases) { theme in
                                    Button(action: {
                                        themeManager.currentTheme = theme
                                    }) {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(theme.accentColor)
                                                .frame(width: 16, height: 16)
                                            Text(theme.displayName)
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            Capsule().fill(Color.clear)
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(
                                                    theme.accentColor,
                                                    lineWidth: themeManager.currentTheme == theme ? 2 : 1
                                                )
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - 챌린지 통계 링크
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

    // MARK: - 차트 뷰들
    var completionChart: some View {
        VStack(alignment: .leading) {
            Text("완료한 챌린지 비율")
                .font(.subheadline)

            let done = completedChallenges.count
            let total = challenges.count
            let percent = total > 0 ? Int((Double(done) / Double(total)) * 100) : 0

            Chart {
                BarMark(x: .value("상태", "완료"), y: .value("개수", done))
                    .foregroundStyle(.green)
                BarMark(x: .value("상태", "미완료"), y: .value("개수", total - done))
                    .foregroundStyle(.red)
            }
            .frame(height: 150)

            Text("총 \(total)개 중 \(done)개 완료 (\(percent)%)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    var categoryChart: some View {
        VStack(alignment: .leading) {
            Text("카테고리별 챌린지 수")
                .font(.subheadline)

            Chart {
                ForEach(categorySummary.sorted(by: { $0.value > $1.value }), id: \.key) { category, count in
                    SectorMark(
                        angle: .value("비율", count),
                        innerRadius: .ratio(0.4),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("카테고리", category))
                }
            }
            .frame(height: 200)
        }
    }

    var durationChart: some View {
        VStack(alignment: .leading) {
            Text("챌린지별 기간 (일 수)")
                .font(.subheadline)

            Chart {
                ForEach(durationByChallenge, id: \.title) { item in
                    BarMark(
                        x: .value("챌린지", item.title),
                        y: .value("일 수", item.days)
                    )
                }
            }
            .frame(height: 200)
        }
    }

    var weekdayChart: some View {
        VStack(alignment: .leading) {
            Text("요일별 챌린지 시작 횟수")
                .font(.subheadline)

            Chart {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    let value = weekdaySummary[day] ?? 0
                    BarMark(
                        x: .value("요일", day),
                        y: .value("개수", value)
                    )
                }
            }
            .frame(height: 200)
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
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(detail)
                        .foregroundColor(Color.primary)
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.primary)
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
                    .foregroundColor(Color.primary)
                Spacer()
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
        }
    }
}
