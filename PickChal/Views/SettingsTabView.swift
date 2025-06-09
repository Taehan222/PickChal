import SwiftUI
import Charts

enum ChallengeStatType: String, CaseIterable, Identifiable {
    case successRate = "성공률"
    case category = "카테고리별"
    case monthly = "월별"

    var id: String { self.rawValue }
}


struct SettingsTabView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @EnvironmentObject var statsVM: StatisticsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showPermissionAlert = false
    var challenges: [ChallengeModel] { statsVM.challengeModels }
    var completedChallenges: [ChallengeModel] { challenges.filter { $0.isCompleted } }
    var ongoingChallenges: [ChallengeModel] { statsVM.ongoingChallenges }

    @State private var selectedStat: ChallengeStatType = .successRate

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: - 통계 뷰
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("나의 챌린지 통계")
                                .font(.title3.bold())

                            Picker("통계 유형", selection: $selectedStat) {
                                ForEach(ChallengeStatType.allCases) { stat in
                                    Text(stat.rawValue).tag(stat)
                                }
                            }
                            .pickerStyle(.segmented)

                            StatisticsView(
                                challengeLogs: statsVM.allLogs.map {
                                    ChallengeLogModel(
                                        id: $0.id ?? UUID(),
                                        date: $0.date ?? Date(),
                                        completed: $0.completed,
                                        challengeID: $0.challenge?.id ?? UUID(),
                                        descriptionText: $0.descriptionText ?? ""
                                    )
                                },
                                challengeModels: statsVM.challengeModels,
                                selectedStat: selectedStat
                            )
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - 테마 선택
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

                    // MARK: - 완료한 챌린지
                    SettingsRowCard(title: "완료한 챌린지", detail: "\(completedChallenges.count)개") {
                        ChallengeCompletedListView(completed: completedChallenges)
                    }
                    .padding(.horizontal)

                    // MARK: - 테스트 알림
                    SettingsCard {
                        Button("테스트 알림 보내기") {
                            NotificationManager.shared.scheduleImmediateTestNotification()
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)

                    // MARK: - 알림 설정
                    SettingsToggleRow(title: "알림 설정", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { isOn in
                            NotificationManager.shared.handleToggleChanged(
                                isOn: isOn,
                                onDenied: {
                                    showPermissionAlert = true
                                    notificationsEnabled = false
                                },
                                onGranted: {
                                    statsVM.registerNotificationsIfNeeded()
                                }
                            )
                        }
                        .alert("알림이 꺼져있습니다",
                               isPresented: $showPermissionAlert) {
                            Button("설정으로 이동") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            Button("취소", role: .cancel) {}
                        } message: {
                            Text("알림을 사용하려면 iOS 설정에서 권한을 허용해 주세요.")
                        }
                        .padding(.horizontal)

                    Spacer(minLength: 48)
                }
                .padding(.top, 20)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .background(themeManager.currentTheme.backgroundColor.opacity(0.1))
            .onAppear {
                statsVM.loadStatistics()
                statsVM.loadUserProfile()
                syncNotificationToggleState()
            }
        }
    }
    func syncNotificationToggleState() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .denied, .notDetermined:
                    notificationsEnabled = false
                case .authorized, .provisional:
                    notificationsEnabled = true
                default:
                    notificationsEnabled = false
                }
            }
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
