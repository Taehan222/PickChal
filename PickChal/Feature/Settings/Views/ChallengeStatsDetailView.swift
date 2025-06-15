//import SwiftUI
//import Charts
//
////enum ChallengeStatType: String, CaseIterable, Identifiable {
////    case successRate = "성공률"
////    case categoryFocus = "가장 많이 한 분야"
////    case longestChallenge = "가장 긴 챌린지"
////    case activeDays = "활동한 요일"
////
////    var id: String { self.rawValue }
////}
//
//struct ChallengeStatsDetailView: View {
//    let challenges: [ChallengeModel]
//    @State private var selectedStat: ChallengeStatType = .successRate
//
//    var completedChallenges: [ChallengeModel] {
//        challenges.filter { $0.isCompleted }
//    }
//
//    var categorySummary: [String: Int] {
//        Dictionary(grouping: challenges, by: { $0.category }).mapValues { $0.count }
//    }
//
//    var longestChallenge: (title: String, days: Int)? {
//        challenges.map {
//            let days = Calendar.current.dateComponents([.day], from: $0.startDate, to: $0.endDate).day ?? 0
//            return (title: $0.title, days: max(days, 0))
//        }
//        .sorted { $0.days > $1.days }
//        .first
//    }
//
//    var weekdaySummary: [String: Int] {
//        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
//        let grouped = Dictionary(grouping: challenges) {
//            let weekday = Calendar.current.component(.weekday, from: $0.startDate)
//            return weekdays[weekday - 1]
//        }
//        return grouped.mapValues { $0.count }
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//                Text("🔥 나의 챌린지 통계")
//                    .font(.title2).bold()
//                    .padding(.top)
//                    .transition(.move(edge: .top).combined(with: .opacity))
//
//                Picker("통계 유형", selection: $selectedStat) {
//                    ForEach(ChallengeStatType.allCases) { stat in
//                        Text(stat.rawValue).tag(stat)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .padding(.bottom)
//
//                Group {
//                    switch selectedStat {
//                    case .successRate:
//                        successRateChart
//                    case .categoryFocus:
//                        categoryFocusChart
//                    case .longestChallenge:
//                        longestChallengeChart
//                    case .activeDays:
//                        activeDaysChart
//                    }
//                }
//                .animation(.spring(), value: selectedStat)
//            }
//            .padding()
//        }
//        .navigationTitle("통계 보기")
//    }
//
//    var successRateChart: some View {
//        let total = challenges.count
//        let success = completedChallenges.count
//        let rate = total > 0 ? Int((Double(success) / Double(total)) * 100) : 0
//
//        return VStack(alignment: .leading, spacing: 12) {
//            Text("챌린지 성공률")
//                .font(.headline)
//            Chart {
//                BarMark(x: .value("상태", "성공"), y: .value("개수", success))
//                    .foregroundStyle(.green.gradient)
//                    .annotation(position: .top) { Text("\(success)") }
//                BarMark(x: .value("상태", "실패"), y: .value("개수", total - success))
//                    .foregroundStyle(.gray.opacity(0.4))
//                    .annotation(position: .top) { Text("\(total - success)") }
//            }
//            .frame(height: 180)
//            .transition(.scale)
//
//            Text("도전 \(total)개 중 \(success)개 완료 (\(rate)%) 🎯")
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//    }
//
//    var categoryFocusChart: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("가장 많이 한 분야")
//                .font(.headline)
//            Chart {
//                ForEach(categorySummary.sorted(by: { $0.value > $1.value }), id: \ .key) { category, count in
//                    SectorMark(
//                        angle: .value("비율", count),
//                        innerRadius: .ratio(0.5),
//                        angularInset: 2
//                    )
//                    .foregroundStyle(by: .value("카테고리", category))
//                    .annotation(position: .overlay) {
//                        Text(category)
//                            .font(.caption2)
//                            .foregroundColor(.white)
//                    }
//                }
//            }
//            .frame(height: 250)
//        }
//    }
//
//    var longestChallengeChart: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("가장 오래한 챌린지")
//                .font(.headline)
//            if let longest = longestChallenge {
//                Text("\(longest.title) - \(longest.days)일 ⏳")
//                    .font(.subheadline)
//                    .foregroundColor(.primary)
//                    .padding(.bottom, 4)
//                Chart {
//                    BarMark(x: .value("챌린지", longest.title), y: .value("일 수", longest.days))
//                        .foregroundStyle(.purple.gradient)
//                        .annotation(position: .top) {
//                            Text("\(longest.days)일")
//                        }
//                }
//                .frame(height: 180)
//            } else {
//                Text("진행한 챌린지가 없습니다.")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//            }
//        }
//    }
//
//    var activeDaysChart: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("가장 자주 시작한 요일")
//                .font(.headline)
//            Chart {
//                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \ .self) { day in
//                    let value = weekdaySummary[day] ?? 0
//                    BarMark(x: .value("요일", day), y: .value("개수", value))
//                        .foregroundStyle(.blue.gradient)
//                        .annotation(position: .top) {
//                            Text("\(value)")
//                                .font(.caption2)
//                        }
//                }
//            }
//            .frame(height: 200)
//        }
//    }
//}
