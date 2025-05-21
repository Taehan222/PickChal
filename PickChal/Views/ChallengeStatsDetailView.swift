import SwiftUI
import Charts

enum ChallengeStatType: String, CaseIterable, Identifiable {
    case completionRate = "완료율"
    case categoryDistribution = "카테고리"
    case progressList = "진행률"

    var id: String { self.rawValue }
}

struct ChallengeStatsDetailView: View {
    let challenges: [ChallengeModel]
    @State private var selectedStat: ChallengeStatType = .completionRate

    // 카테고리별 개수 요약 (임시로 서브타이틀활용)
    var categorySummary: [String: Int] {
        Dictionary(grouping: challenges, by: { $0.subtitle }) // 추후에 카테고리로 변경
            .mapValues { $0.count }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 제목
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

                // 통계별 콘텐츠
                Group {
                    switch selectedStat {
                    case .completionRate:
                        completionRateChart
                    case .categoryDistribution:
                        categoryPieChart
                    case .progressList:
                        progressListSection
                    }
                }
            }
            .padding()
        }
        .navigationTitle("통계 보기")
        .accentColor(Theme.Colors.primary)
    }

    // 완료율 Bar Chart
    var completionRateChart: some View {
        VStack(alignment: .leading) {
            Text("챌린지별 완료율")
                .font(.headline)

            Chart(challenges) { challenge in
                BarMark(
                    x: .value("챌린지", challenge.title),
                    y: .value("완료 비율", Double(challenge.completedCount) / Double(challenge.totalCount))
                )
                .foregroundStyle(.green)
            }
            .frame(height: 200)
        }
    }

    // 카테고리 분포 Pie Chart(임시 서브타이틀)
    var categoryPieChart: some View {
        VStack(alignment: .leading) {
            Text("카테고리 분포 (subtitle 기준)")
                .font(.headline)

            Chart {
                ForEach(Array(categorySummary.keys), id: \.self) { category in
                    let value = categorySummary[category] ?? 0
                    SectorMark(
                        angle: .value("비율", value),
                        innerRadius: .ratio(0.4),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("카테고리", category))
                }
            }
            .frame(height: 250)
        }
    }

    //챌린지 진행률 리스트
    var progressListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 진행률 목록")
                .font(.headline)

            ForEach(challenges) { challenge in
                VStack(alignment: .leading, spacing: 6) {
                    Text(challenge.title)
                        .bold()
                    ProgressView(value: Float(challenge.completedCount), total: Float(challenge.totalCount))
                        .accentColor(.blue)
                }
                .padding(.vertical, 6)
            }
        }
    }
}
