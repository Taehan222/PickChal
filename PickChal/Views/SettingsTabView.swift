import SwiftUI
import Charts
import Foundation

struct DummyData {
    static let user = UserModel(
        year: 2001,
        mbti: .INTJ,
        interests: [.운동, .자기계발],
        priority: .시간관리,
        routineDifficulty: .thirtyMinutes,
        goalDescription: "마음의 평화와 시간 관리 능력 향상"
    )

    // 전체 챌린지 (진행 중 + 완료 포함)
    static let challenges: [ChallengeModel] = [
        ChallengeModel(id: UUID(), title: "기상 7시 챌린지", subtitle: "하루를 일찍 시작해보자!", totalCount: 14, completedCount: 14, date: Date()), // 완료
        ChallengeModel(id: UUID(), title: "독서 30분", subtitle: "하루 30분 책 읽기", totalCount: 10, completedCount: 10, date: Date()), // 완료
        ChallengeModel(id: UUID(), title: "물 2L 마시기", subtitle: "매일 물 충분히 마시기", totalCount: 7, completedCount: 4, date: Date()) // 진행 중
    ]

    //완료된 챌린지만 필터링
    static let completedChallenges: [ChallengeModel] = challenges.filter {
        $0.completedCount >= $0.totalCount
    }
}



struct SettingsTabView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkMode") private var darkMode = false

    let user: UserModel = DummyData.user
    let challenges: [ChallengeModel] = DummyData.challenges


    var challengeCompletionRate: Int {
        let total = challenges.map { $0.totalCount }.reduce(0, +)
        let completed = challenges.map { $0.completedCount }.reduce(0, +)
        guard total > 0 else { return 0 }
        return Int((Double(completed) / Double(total)) * 100)
    }

    var completedChallenges: [ChallengeModel] {
        challenges.filter { $0.completedCount >= $0.totalCount }
    }

    var body: some View {
        NavigationView {
            Form {

                Section(header: Text("프로필")) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.red)

                        VStack(alignment: .leading, spacing: 4) {
                            Label("출생: \(user.year)", systemImage: "calendar")
                            Label("MBTI: \(user.mbti.rawValue)", systemImage: "brain.head.profile")
                            Label("관심사: \(user.interests.map { $0.rawValue }.joined(separator: ", "))", systemImage: "sparkles")
                        }
                        .font(.subheadline)
                    }

                    NavigationLink(destination: Text("프로필 수정 뷰")) {
                        Label("프로필 편집", systemImage: "pencil")
                    }
                }
                Section(header: Text("챌린지 통계")) {
                    NavigationLink(destination: ChallengeStatsDetailView(challenges: challenges)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("전체 챌린지 완료율")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text("\(challengeCompletionRate)% 완료")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                            Image(systemName: "chart.bar.xaxis")
                                .foregroundColor(.green)
                        }
                    }
                }

          
                Section(header: Text("완료한 챌린지")) {
                    NavigationLink(destination: ChallengeCompletedListView(completed: completedChallenges)) {
                        HStack {
                            Text("완료한 챌린지 \(completedChallenges.count)개")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }

                
                Section(header: Text("설정")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("알림 설정", systemImage: "bell.fill")
                    }

                    Toggle(isOn: $darkMode) {
                        Label("다크 모드", systemImage: "moon.stars.fill")
                    }
                }

                
                Section {
                    Button(role: .destructive) {
                        print("계정 초기화")
                    } label: {
                        Label("유저 정보 초기화", systemImage: "trash")
                    }
                }
            }
            .accentColor(Theme.Colors.primary)
            .navigationTitle("내 정보")
        }
    }
}

#Preview {
    SettingsTabView()
}

