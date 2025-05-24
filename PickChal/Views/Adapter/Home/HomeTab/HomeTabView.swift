import SwiftUI

struct HomeTabView: View {
    @State private var selectedDate = Date()
    @ObservedObject var viewModel = ChallengeViewModel()
    @StateObject private var tabViewModel = HomeTabViewModel()

    var body: some View {
        VStack(spacing: 15) {
            FSCalendarView(selectedDate: $selectedDate)
                .frame(height: 300)

            ScrollView {
                VStack(spacing: 16) {
                    section(
                        title: "진행중인 챌린지",
                        challenges: viewModel.goingChallenges,
                        emptyMessage: "진행중인 챌린지가 없습니다.",
                        icon: "checkmark.circle",
                        iconColor: .blue
                    ) { id in
                        tabViewModel.showCompletionAlert(for: id)
                    }

                    section(
                        title: "완료된 챌린지",
                        challenges: viewModel.completedChallenges,
                        emptyMessage: "아직 완료된 챌린지가 없습니다.",
                        icon: "xmark.circle.fill",
                        iconColor: .red
                    ) { id in
                        viewModel.goingChallenge(id: id)
                    }
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding(.vertical)
        .alert("챌린지를 완료했나요?", isPresented: $tabViewModel.showAlert) {
            Button("완료") {
                tabViewModel.completeChallenge(in: viewModel)
            }
            Button("아니요", role: .cancel) { }
        }
    }
    
    // 챌린지 뷰
    func section(
        title: String,
        challenges: [ChallengeModel],
        emptyMessage: String,
        icon: String,
        iconColor: Color,
        action: @escaping (UUID) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.leading)
            // 챌린지가 없을 때
            if challenges.isEmpty {
                emptyLabel(text: emptyMessage)
            } else {
                // 챌린지 카드 리스트
                LazyVStack(spacing: 8) {
                    ForEach(challenges) { challenge in
                        challengeCard(challenge: challenge, icon: icon, iconColor: iconColor) {
                            action(challenge.id)
                        }
                    }
                }
            }
        }
    }
    // 챌린지 없을 때
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
    
    // 챌린지 카드 뷰
    func challengeCard(
        challenge: ChallengeModel,
        icon: String,
        iconColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title)
                    .font(.system(size: 18, weight: .bold))
                Text(challenge.descriptionText)
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
