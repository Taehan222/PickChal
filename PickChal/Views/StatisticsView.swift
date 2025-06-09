import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    var challengeLogs: [ChallengeLogModel]
    var challengeModels: [ChallengeModel]
    var selectedStat: ChallengeStatType

    struct CategorySuccess: Identifiable {
        let id = UUID()
        let category: String
        let successRate: Int
    }

    struct MonthlySuccess: Identifiable {
        let id = UUID()
        let month: String
        let count: Int
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            switch selectedStat {
            case .successRate:
                currentStreakSection
            case .category:
                categorySuccessRateChart
            case .monthly:
                monthlySuccessChart
            }
        }
    }

    // MARK: - Current Streak
    var currentStreakSection: some View {
        let streak = calculateCurrentStreak()

        return VStack(alignment: .leading, spacing: 8) {
            Text("연속 성공일")
                .font(.title3.bold())
                .padding(.horizontal)

            Text("\(streak)일 연속 성공 중!")
                .font(.largeTitle.bold())
                .foregroundColor(themeManager.currentTheme.accentColor)
                .padding(.horizontal)
        }
    }


    func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // 완료된 로그를 날짜 기준으로 오름차순 정렬
        let sortedDates = challengeLogs
            .filter { $0.completed }
            .map { calendar.startOfDay(for: $0.date) }
            .sorted()

        var streak = 0
        var expectedDate = today

        for date in sortedDates.reversed() {
            if calendar.isDate(date, inSameDayAs: expectedDate) {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
            } else if date < expectedDate {
                break
            }
        }

        return streak
    }


    // MARK: - Category Success Rate
    var categorySuccessRateChart: some View {
        let data = calculateCategorySuccessRates()

        return VStack(alignment: .leading, spacing: 12) {
            Text("카테고리별 성공률")
                .font(.title3.bold())
                .padding(.horizontal)

            Chart(data) { item in
                BarMark(
                    x: .value("카테고리", item.category),
                    y: .value("성공률", item.successRate)
                )
                .cornerRadius(6)
                .foregroundStyle(themeManager.currentTheme.accentColor.gradient)
                .annotation(position: .top) {
                    Text("\(item.successRate)%")
                        .font(.caption2.bold())
                        .foregroundColor(.primary)
                }
            }
            .frame(height: 220)
            .padding(.horizontal)
        }
    }

    func calculateCategorySuccessRates() -> [CategorySuccess] {
        var grouped: [String: [ChallengeLogModel]] = [:]

        for log in challengeLogs {
            if let challenge = challengeModels.first(where: { $0.id == log.challengeID }) {
                grouped[challenge.category, default: []].append(log)
            }
        }

        return grouped.map { (category, logs) in
            let total = logs.count
            let completed = logs.filter { $0.completed }.count
            let rate = total > 0 ? Int((Double(completed) / Double(total)) * 100) : 0
            return CategorySuccess(category: category, successRate: rate)
        }
    }

    // MARK: - Monthly Success Count
    var monthlySuccessChart: some View {
        let monthly = calculateMonthlySuccess()

        return VStack(alignment: .leading, spacing: 12) {
            Text("월별 성공 개수")
                .font(.title3.bold())
                .padding(.horizontal)

            Chart(monthly) { item in
                BarMark(
                    x: .value("월", item.month),
                    y: .value("성공 수", item.count)
                )
                .cornerRadius(6)
                .foregroundStyle(themeManager.currentTheme.accentColor.gradient)
                .annotation(position: .top) {
                    Text("\(item.count)")
                        .font(.caption2.bold())
                        .foregroundColor(.primary)
                }
            }
            .frame(height: 220)
            .padding(.horizontal)
        }
    }

    func calculateMonthlySuccess() -> [MonthlySuccess] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"

        let completedLogs = challengeLogs.filter { $0.completed }
        let grouped = Dictionary(grouping: completedLogs, by: { formatter.string(from: $0.date) })

        return grouped.map { (month, logs) in
            MonthlySuccess(month: month, count: logs.count)
        }.sorted { $0.month < $1.month }
    }
}
