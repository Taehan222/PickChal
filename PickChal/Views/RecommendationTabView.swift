//
//  Recommendation.swift
//  SampleApp03
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI
import ChatGPTSwift

struct RecommendationTabView: View {
    @EnvironmentObject var tabManager: TabSelectionManager
    @StateObject private var viewModel = RecommendationViewModel()
    @State private var showCards: [Bool] = []
    @State private var selectedChallenge: RecommendationModel? = nil
    @State private var showOnboardingGoal = false
    @State private var userGoal: String = ""

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
            .onChange(of: tabManager.selectedTab) { newTab in
                if newTab == AppTab.recommend.rawValue {
                    showOnboardingGoal = true
                }
            }
            .fullScreenCover(isPresented: $showOnboardingGoal) {
                OnboardingGoalViewWrapper { goal in
                    userGoal = goal
                    saveGoalToUserProfile(goal)
                    loadRecommendations(goal: goal)
                }
            }
        }
        .background(Theme.Colors.background.edgesIgnoringSafeArea(.all))
    }

    private func saveGoalToUserProfile(_ goal: String) {
        guard let profile = profiles.first else { return }
        profile.goal = goal
        do {
            try CoreDataManager.shared.container.viewContext.save()
            print("사용자 목표 저장 완료: \(goal)")
        } catch {
            print("사용자 목표 저장 실패: \(error.localizedDescription)")
        }
    }

    private func loadRecommendations(goal: String) {
        guard let profile = profiles.first else {
            print("프로필이 없습니다.")
            return
        }
        let user = UserModel(
            year: Int(profile.year),
            mbti: MBTIType(rawValue: profile.mbti ?? "") ?? .INTJ,
            priority: .운동,
            goal: goal,
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
        .environmentObject(TabSelectionManager.shared)
}
