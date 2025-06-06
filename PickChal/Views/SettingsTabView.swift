import SwiftUI
import Charts

struct SettingsTabView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @EnvironmentObject var statsVM: StatisticsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedStat: ChallengeStatType = .successRate

    var challenges: [ChallengeModel] { statsVM.challengeModels }
    var completedChallenges: [ChallengeModel] { challenges.filter { $0.isCompleted } }
    var ongoingChallenges: [ChallengeModel] { challenges.filter { !$0.isCompleted } }

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
                VStack(alignment: .leading, spacing: 24) {

                    SettingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("나의 챌린지 통계")
                                .font(.title3.bold())

                            Picker("통계 유형", selection: $selectedStat) {
                                ForEach(ChallengeStatType.allCases) { stat in
                                    Text(stat.rawValue).tag(stat)
                                }
                            }
                            .pickerStyle(.segmented)

                            Group {
                                switch selectedStat {
                                case .successRate: successRateChart
                                case .categoryFocus: categoryFocusChart
                                case .activeDays: activeDaysChart
                                case .longestChallenge: longestChallengeChart
                                }
                            }
                            .transition(.opacity.combined(with: .slide))
                            .animation(.spring(), value: selectedStat)
                        }
                    }
                    .padding(.horizontal)

                    SettingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("테마 선택")
                                .font(.headline)

                            HStack(spacing: 20) {
                                ForEach(AppTheme.allCases) { theme in
                                    Circle()
                                        .fill(theme.accentColor)
                                        .frame(width: themeManager.currentTheme == theme ? 44 : 32,
                                               height: themeManager.currentTheme == theme ? 44 : 32)
                                        .overlay(
                                            Circle()
                                                .stroke(themeManager.currentTheme == theme ? Color.primary : Color.clear, lineWidth: 2)
                                        )
                                        .onTapGesture {
                                            withAnimation {
                                                themeManager.updateTheme(theme)
                                            }
                                        }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)

                    SettingsRowCard(title: "완료한 챌린지", detail: "\(completedChallenges.count)개") {
                        ChallengeCompletedListView(completed: completedChallenges)
                    }
                    .padding(.horizontal)

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
                        .padding(.horizontal)

                    Spacer(minLength: 48)
                }
                .padding(.top, 20)
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .background(themeManager.currentTheme.backgroundColor.opacity(0.1))
            .onAppear {
                statsVM.loadStatistics()
                statsVM.loadUserProfile()
            }
        }
    }

    // MARK: - 차트 뷰들
    var successRateChart: some View {
        let done = completedChallenges.count
        let total = challenges.count
        let percent = total > 0 ? Int((Double(done) / Double(total)) * 100) : 0

        return VStack(alignment: .leading, spacing: 8) {
            Text("성공률")
                .font(.headline)

            Chart {
                BarMark(x: .value("상태", "성공"), y: .value("개수", done))
                    .foregroundStyle(themeManager.currentTheme.accentColor.gradient)
                    .annotation(position: .top) { Text("\(done)") }
                BarMark(x: .value("상태", "실패"), y: .value("개수", total - done))
                    .foregroundStyle(.gray.opacity(0.3))
                    .annotation(position: .top) { Text("\(total - done)") }
            }
            .frame(height: 160)

            Text("총 \(total)개 중 \(done)개 성공 (\(percent)%)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    var categoryFocusChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("가장 많이 한 분야")
                .font(.headline)

            Chart {
                ForEach(categorySummary.sorted(by: { $0.value > $1.value }), id: \ .key) { category, count in
                    SectorMark(
                        angle: .value("비율", count),
                        innerRadius: .ratio(0.4),
                        angularInset: 3
                    )
                    .foregroundStyle(by: .value("카테고리", category))
                    .annotation(position: .overlay) {
                        Text(category).font(.caption2).foregroundColor(.white)
                    }
                }
            }
            .frame(height: 220)
        }
    }

    var longestChallengeChart: some View {
        let longest = durationByChallenge.max(by: { $0.days < $1.days })

        return VStack(alignment: .leading, spacing: 8) {
            Text("가장 긴 챌린지")
                .font(.headline)

            if let item = longest {
                Chart {
                    BarMark(x: .value("챌린지", item.title), y: .value("일 수", item.days))
                        .foregroundStyle(.purple.gradient)
                        .annotation(position: .top) {
                            Text("\(item.days)일").font(.caption2)
                        }
                }
                .frame(height: 180)
            } else {
                Text("진행한 챌린지가 없습니다.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    var activeDaysChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("활동한 요일")
                .font(.headline)

            Chart {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \ .self) { day in
                    let value = weekdaySummary[day] ?? 0
                    BarMark(x: .value("요일", day), y: .value("개수", value))
                        .foregroundStyle(themeManager.currentTheme.accentColor.gradient)
                        .annotation(position: .top) {
                            Text("\(value)").font(.caption2)
                        }
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
