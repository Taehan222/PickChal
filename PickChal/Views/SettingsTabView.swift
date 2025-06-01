import SwiftUI
import Charts

// DummyData
struct DummyData {
    static let user = UserModel(
        year: 2001,
        mbti: .INTJ,
        priority: .시간관리,
        goal: "마음의 평화와 시간 관리 능력 향상",
        isOnboardingCompleted: true // 모델 변경으로 항목 추가했어요
    )

    static let challenges: [ChallengeModel] = [
        ChallengeModel(
            id: UUID(),
            title: "기상 7시 챌린지",
            subTitle: "하루를 일찍 시작해보자!",
            descriptionText: "매일 아침 7시에 일어나기",
            category: "시간관리",
            startDate: Date(),
            endDate: Date(),
            totalCount: 14,
            createdAt: Date(),
            alarmTime: Date(),
            isCompleted: true
        ),
        ChallengeModel(
            id: UUID(),
            title: "독서 30분",
            subTitle: "하루 30분 책 읽기",
            descriptionText: "꾸준한 독서를 통한 자기계발",
            category: "자기계발",
            startDate: Date(),
            endDate: Date(),
            totalCount: 10,
            createdAt: Date(),
            alarmTime: Date(),
            isCompleted: true
        ),
        ChallengeModel(
            id: UUID(),
            title: "물 2L 마시기",
            subTitle: "매일 물 충분히 마시기",
            descriptionText: "건강한 수분 섭취 습관",
            category: "건강",
            startDate: Date(),
            endDate: Date(),
            totalCount: 7,
            createdAt: Date(),
            alarmTime: Date(),
            isCompleted: false
        )
    ]
}




struct SettingsTabView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @EnvironmentObject var statsVM: StatisticsViewModel

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
                                    .font(.title2).bold()

                                VStack(alignment: .leading, spacing: 8) {
                                    profileRow(title: "출생", value: "\(user.year)년생")
                                    profileRow(title: "MBTI", value: user.mbti.rawValue)
                                    profileRow(title: "우선순위", value: user.priority.rawValue)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("목표")
                                            .fontWeight(.semibold)
                                        Text(user.goal)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.top, 6)
                                }
                                .padding()
                                .background(Color(white: 0.97))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }

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
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}
struct SettingsRowCard<Destination: View>: View {
    let title: String
    let detail: String
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Text(detail)
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(white: 0.97))
            .cornerRadius(12)
        }
    }
}

struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(Color(white: 0.97))
        .cornerRadius(12)
    }
}

struct SettingsActionRow: View {
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
            .background(Color(white: 0.97))
            .cornerRadius(12)
        }
    }
}

