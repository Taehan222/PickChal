import SwiftUI
import Charts

enum ChallengeStatType: String, CaseIterable, Identifiable {
    case completionRate = "완료율"
    case categoryDistribution = "카테고리"
    case durationDistribution = "챌린지 기간"
    case weekdayStart = "요일별 시작"

    var id: String { self.rawValue }
}

struct ChallengeStatsDetailView: View {
    let challenges: [ChallengeModel]
    @State private var selectedStat: ChallengeStatType = .completionRate

    var completedCount: Int {
        challenges.filter { $0.isCompleted }.count
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
        let grouped = Dictionary(grouping: challenges) { challenge in
            let weekday = Calendar.current.component(.weekday, from: challenge.startDate) // 1 = Sunday
            return weekdays[weekday - 1]
        }
        return grouped.mapValues { $0.count }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("챌린지 상세 통계")
                    .font(.title2).bold()
                    .padding(.top)

                Picker("통계 유형", selection: $selectedStat) {
                    ForEach(ChallengeStatType.allCases) { stat in
                        Text(stat.rawValue).tag(stat)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom)

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
            .padding()
        }
        .navigationTitle("통계 보기")
        .accentColor(Theme.Colors.primary)
    }

    // 완료
    var completionChart: some View {
        VStack(alignment: .leading) {
            Text("완료한 챌린지 비율")
                .font(.headline)

            let done = completedCount
            let total = challenges.count
            let percent = total > 0 ? Int((Double(done) / Double(total)) * 100) : 0

            Chart {
                BarMark(x: .value("상태", "완료"), y: .value("개수", done))
                    .foregroundStyle(.green)
                BarMark(x: .value("상태", "미완료"), y: .value("개수", total - done))
                    .foregroundStyle(.red)
            }
            .frame(height: 200)

            Text("총 \(total)개 중 \(done)개 완료 (\(percent)%)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    // 카테고리 분포
    var categoryChart: some View {
        VStack(alignment: .leading) {
            Text("카테고리별 챌린지 수")
                .font(.headline)

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
            .frame(height: 250)
        }
    }

    //챌린지 기간 분포
    var durationChart: some View {
        VStack(alignment: .leading) {
            Text("챌린지별 기간 (일 수)")
                .font(.headline)

            Chart {
                ForEach(durationByChallenge, id: \.title) { item in
                    BarMark(
                        x: .value("챌린지", item.title),
                        y: .value("일 수", item.days)
                    )
                }
            }
            .frame(height: 250)
        }
    }

    //요일별 시작 분포
    var weekdayChart: some View {
        VStack(alignment: .leading) {
            Text("요일별 챌린지 시작 횟수")
                .font(.headline)

            Chart {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    let value = weekdaySummary[day] ?? 0
                    BarMark(
                        x: .value("요일", day),
                        y: .value("개수", value)
                    )
                }
            }
            .frame(height: 220)
        }
    }
}
