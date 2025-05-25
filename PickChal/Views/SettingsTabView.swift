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
    @AppStorage("darkMode") private var darkMode = false

    let user: UserModel = DummyData.user
    let challenges: [ChallengeModel] = DummyData.challenges

    var completedChallenges: [ChallengeModel] {
        challenges.filter { $0.isCompleted }
    }

    var challengeCompletionRate: Int {
        let total = challenges.count
        guard total > 0 else { return 0 }
        let completed = completedChallenges.count
        return Int((Double(completed) / Double(total)) * 100)
    }

    var body: some View {
        NavigationView {
            Form {
                // 프로필
                Section(header: Text("프로필")) {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.red)

                        VStack(alignment: .leading, spacing: 4) {
                            Label("출생: \(user.year)", systemImage: "calendar")
                            Label("MBTI: \(user.mbti.rawValue)", systemImage: "brain.head.profile")
                            Label("우선순위: \(user.priority.rawValue)", systemImage: "flag")
                            Label("목표: \(user.goal)", systemImage: "target")
                        }
                        .font(.subheadline)
                    }

                    NavigationLink(destination: Text("프로필 수정 뷰")) {
                        Label("프로필 편집", systemImage: "pencil")
                    }
                }

                // 챌린지 통계
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

                // 완료한 챌린지
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

                // 설정
                Section(header: Text("설정")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("알림 설정", systemImage: "bell.fill")
                    }

                    Toggle(isOn: $darkMode) {
                        Label("다크 모드", systemImage: "moon.stars.fill")
                    }
                }
                //테스트용
                Section(header: Text("알림 테스트")) {
                    Button {
                        if let firstChallenge = challenges.first {
                            NotificationManager.shared.scheduleImmediateTestNotification(for: firstChallenge)
                        }
                    } label: {
                        Label("🔔 테스트 알림 보내기", systemImage: "paperplane")
                    }
                }

                // 초기화
                Section {
                    Button(role: .destructive) {
                        print("계정 초기화")
                    } label: {
                        Label("유저 정보 초기화", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("내 정보")
        }
    }
}

#Preview {
    SettingsTabView()
}
