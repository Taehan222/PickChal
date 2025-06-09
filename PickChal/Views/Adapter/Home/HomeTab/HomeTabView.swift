import SwiftUI
import CoreData
import FSCalendar

struct HomeTabView: View {
    @State private var selectedDate = Date()
    @State private var calendarHeight: CGFloat = 300
    @StateObject private var tabViewModel = HomeTabViewModel()
    @EnvironmentObject var themeManager: ThemeManager

    @FetchRequest(
        entity: ChallengeLog.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ChallengeLog.date, ascending: true)]
    ) private var logs: FetchedResults<ChallengeLog>

    var body: some View {
        VStack(spacing: 15) {
            CalendarView(selectedDate: $selectedDate, calendarHeight: $calendarHeight)
                .frame(height: calendarHeight)

            ScrollView {
                VStack(spacing: 16) {
                    let logsForDate = logs.filter { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: selectedDate) }

                    section(
                        title: "진행중인 챌린지",
                        logs: logsForDate.filter { !$0.completed },
                        emptyMessage: "진행중인 챌린지가 없습니다.",
                        icon: "checkmark.circle",
                        iconColor: .blue,
                        showButton: Calendar.current.isDateInToday(selectedDate)
                    ) { log in
                        tabViewModel.showCompletionAlert(for: log.id ?? UUID())
                    }

                    section(
                        title: "완료된 챌린지",
                        logs: logsForDate.filter { $0.completed },
                        emptyMessage: "아직 완료된 챌린지가 없습니다.",
                        icon: "xmark.circle.fill",
                        iconColor: .red,
                        showButton: false
                    ) { _ in }
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .alert("챌린지를 완료했나요?", isPresented: $tabViewModel.showAlert) {
            Button("완료") {
                if let id = tabViewModel.selectedChallengeID,
                   let log = logs.first(where: { $0.id == id }),
                   let challenge = log.challenge {
                    let context = CoreDataManager.shared.container.viewContext
                    log.completed = true
                    NotificationManager.shared.markTodayAlarmAsSkipped(for: challenge.toModel())

                    let fetchRequest: NSFetchRequest<ChallengeLog> = ChallengeLog.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "challenge == %@", challenge)
                    do {
                        let allLogs = try context.fetch(fetchRequest)
                        let allCompleted = allLogs.allSatisfy { $0.completed }
                        challenge.isCompleted = allCompleted
                        if(challenge.isCompleted) {
                            NotificationManager.shared.removeChallenge(challenge.id!)
                        }
                        try context.save()
                        

                        print("챌린지 완료 상태 업데이트됨")
                    } catch {
                        print("업데이트 실패: \(error.localizedDescription)")
                    }
                }
                tabViewModel.showAlert = false
            }
            Button("아니요", role: .cancel) { }
        }
    }

    func section(
        title: String,
        logs: [ChallengeLog],
        emptyMessage: String,
        icon: String,
        iconColor: Color,
        showButton: Bool,
        action: @escaping (ChallengeLog) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(themeManager.currentTheme.font)
                .foregroundColor(Color.primary)
                .padding(.leading)
            if logs.isEmpty {
                emptyLabel(text: emptyMessage)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(logs, id: \.self) { log in
                        challengeCard(log: log, icon: icon, iconColor: iconColor, showButton: showButton) {
                            action(log)
                        }
                    }
                }
            }
        }
    }

    func emptyLabel(text: String) -> some View {
        HStack {
            Text(text)
                .foregroundColor(.secondary)
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.accentColor.opacity(0.2), lineWidth: 2)
        )
        .padding(.horizontal)
    }

    func challengeCard(
        log: ChallengeLog,
        icon: String,
        iconColor: Color,
        showButton: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let challengeTitle = log.challenge?.title ?? "제목 없음"
        let logDescription = log.descriptionText ?? "설명 없음"

        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(challengeTitle)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.primary)
                Text(logDescription)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            Spacer()
            if showButton {
                Button(action: action) {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.accentColor, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    HomeTabView()
        .environmentObject(ThemeManager())
}
