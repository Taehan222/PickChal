import SwiftUI
import Charts

struct ChallengeStatsDetailView: View {
    let challenges: [ChallengeModel]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("챌린지 상세 통계")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                // 막대 차트
                Chart(challenges) { challenge in
                    BarMark(
                        x: .value("챌린지", challenge.title),
                        y: .value("완료 비율", Double(challenge.completedCount) / Double(challenge.totalCount))
                    )
                    .foregroundStyle(.green)
                }
                .frame(height: 200)

                // 텍스트 통계 요약
                ForEach(challenges) { challenge in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(challenge.title).bold()
                        ProgressView(value: Float(challenge.completedCount), total: Float(challenge.totalCount))
                    }
                }
            }
            .padding()
        }
        .accentColor(Theme.Colors.primary)
        .navigationTitle("통계 보기")
    }
}
