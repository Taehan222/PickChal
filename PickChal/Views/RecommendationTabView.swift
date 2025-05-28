//
//  Recommendation.swift
//  SampleApp03
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI
import ChatGPTSwift

struct RecommendationTabView: View {
    @StateObject private var viewModel = RecommendationViewModel()
    @State private var showCards: [Bool] = []
    @State private var selectedChallenge: RecommendationModel? = nil
    // coredata에서 userprofile 불러오기
    @FetchRequest(
        entity: UserProfile.entity(),
        sortDescriptors: []
    ) private var profiles: FetchedResults<UserProfile>

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("추천 로딩 중...")
                } else if let error = viewModel.errorMessage {
                    ScrollView {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                } else {
                    ScrollView {
                        if viewModel.recommendations.isEmpty {
                            Text("더이상 챌린지가 없습니다")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .padding(.top, 100)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(Array(viewModel.recommendations.enumerated()), id: \.1.id) { index, rec in
                                    CardView(
                                        title: rec.title,
                                        subtitle: rec.descriptionText,
                                        iconName: rec.iconName
                                    )
                                    .onTapGesture {
                                        selectedChallenge = rec
                                    }
                                    .opacity(showCards.indices.contains(index) && showCards[index] ? 1 : 0)
                                    .offset(y: showCards.indices.contains(index) && showCards[index] ? 0 : 20)
                                    .animation(.easeOut.delay(Double(index) * 0.2), value: showCards)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("챌린지 추천")
            .sheet(item: $selectedChallenge) { challenge in
                ChallengeDetailModalView(challenge: challenge) {
                    if let index = viewModel.recommendations.firstIndex(where: { $0.id == challenge.id }) {
                        viewModel.recommendations.remove(at: index)
                        showCards.remove(at: index)
                    }
                    selectedChallenge = nil
                }
                .presentationDetents([.medium])
            }
            .onAppear {
                loadRecommendations()
            }
        }
        .background(Theme.Colors.background.edgesIgnoringSafeArea(.all))
    }
    // coredata의 사용자 정보로 챌린지 불러오기
    private func loadRecommendations() {
        guard let profile = profiles.first else {
            return
        }
        // 사용자 정보 usermodel로 변환
        let user = UserModel(
            year: Int(profile.year),
            mbti: MBTIType(rawValue: profile.mbti ?? "") ?? .INTJ,
            priority: .운동,
            goal: profile.goal ?? "",
            isOnboardingCompleted: profile.onboardingCompleted
        )
        Task {
            await viewModel.load(user: user)
            showCards = Array(repeating: false, count: viewModel.recommendations.count)
            for i in showCards.indices {
                try? await Task.sleep(nanoseconds: 200_000_000)
                showCards[i] = true
            }
        }
    }
}


#Preview {
    RecommendationTabView()
}
