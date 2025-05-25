import SwiftUI

struct HomeTabView: View {
    @State private var selectedDate = Date()
    @ObservedObject var viewModel = ChallengeViewModel()
    @StateObject private var tabViewModel = HomeTabViewModel()
    @FetchRequest(
        entity: Challenge.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Challenge.createdAt, ascending: true)]
    ) private var challenges: FetchedResults<Challenge>

    var body: some View {
        VStack(spacing: 15) {
            FSCalendarView(selectedDate: $selectedDate)
                .frame(height: 300)

            ScrollView {
                VStack(spacing: 16) {
                    section(
                        title: "진행중인 챌린지",
                        challenges: challenges.filter { !$0.isCompleted },
                        emptyMessage: "진행중인 챌린지가 없습니다.",
                        icon: "checkmark.circle",
                        iconColor: .blue
                    ) { challenge in
                        tabViewModel.showCompletionAlert(for: challenge.id ?? UUID())
                    }

                    section(
                        title: "완료된 챌린지",
                        challenges: challenges.filter { $0.isCompleted },
                        emptyMessage: "아직 완료된 챌린지가 없습니다.",
                        icon: "xmark.circle.fill",
                        iconColor: .red
                    ) { challenge in
                        tabViewModel.reactivateChallenge(challenge: challenge)
                    }
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding(.vertical)
        // 나중에는 챌린지 title 받아서 알람창 수정 예정
        .alert("챌린지를 완료했나요?", isPresented: $tabViewModel.showAlert) {
            Button("완료") {
                tabViewModel.completeChallenge()
            }
            Button("아니요", role: .cancel) { }
        }
    }

    func section(
        title: String,
        challenges: [Challenge],
        emptyMessage: String,
        icon: String,
        iconColor: Color,
        action: @escaping (Challenge) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.leading)
            if challenges.isEmpty {
                emptyLabel(text: emptyMessage)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(challenges, id: \.self) { challenge in
                        challengeCard(challenge: challenge, icon: icon, iconColor: iconColor) {
                            action(challenge)
                        }
                    }
                }
            }
        }
    }

    func emptyLabel(text: String) -> some View {
        HStack {
            Text(text)
                .foregroundColor(.gray)
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }

    func challengeCard(
        challenge: Challenge,
        icon: String,
        iconColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title ?? "제목 없음")
                    .font(.system(size: 18, weight: .bold))
                Text(challenge.descriptionText ?? "설명 없음")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: action) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    HomeTabView()
}
