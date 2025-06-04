//
//  RecommendationTabView.swift
//  SampleApp03
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI
import ChatGPTSwift
import CoreData

struct RecommendationTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var tabManager: TabSelectionManager
    @StateObject private var viewModel = RecommendationViewModel()
    @State private var showCards: [Bool] = []
    @State private var selectedChallenge: RecommendationModel? = nil
    @State private var showOnboardingGoal = false
    @State private var userGoal: String = ""
    
    @FetchRequest(entity: UserProfile.entity(), sortDescriptors: []) private var profiles: FetchedResults<UserProfile>
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("챌린지 추천")
                .sheet(item: $selectedChallenge) { challenge in
                    ChallengeDetailModalView(challenge: challenge) {
                        if let index = viewModel.recommendations.firstIndex(where: { $0.id == challenge.id }) {
                            viewModel.recommendations.remove(at: index)
                            showCards.remove(at: index)

                        }
                        selectedChallenge = nil
                    }
                }
                .onAppear {
                    if tabManager.selectedTab == AppTab.recommend.rawValue {
                        showOnboardingGoal = true
                    }
                }

                .onChange(of: tabManager.selectedTab) { newTab in
                    if newTab == AppTab.recommend.rawValue {
                        showOnboardingGoal = true
                    }
                }
                .fullScreenCover(isPresented: $showOnboardingGoal) {
                    
                    ZStack(alignment: .topTrailing) {
                        OnboardingGoalViewWrapper(isPresented: $showOnboardingGoal) { goal in
                            userGoal = goal
                            saveGoalToUserProfile(goal)
                            loadRecommendations(goal: goal)
                        }
                        
                        Button(action: {
                            showOnboardingGoal = false
                            tabManager.selectedTab = AppTab.home.rawValue
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                }
        }
        .background(Theme.Colors.background.edgesIgnoringSafeArea(.all))
    }
    
    @ViewBuilder
    private var contentView: some View {
        Group {
            if let error = viewModel.errorMessage {
                errorView(error)
            } else {
                recommendationsScrollView
            }
        }
    }
    
    private func errorView(_ error: String) -> some View {
        ScrollView {
            Text(error)
                .foregroundColor(.red)
                .padding()
        }
    }
    
    private var recommendationsScrollView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.recommendations) { rec in
                    CardView(
                        title: rec.title,
                        subtitle: rec.descriptionText,
                        iconName: rec.iconName,
                        iconColorName: rec.iconColor
                    )
                    .onTapGesture {
                        selectedChallenge = rec
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .transition(.opacity)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.top)
            .animation(.easeOut(duration: 0.5), value: viewModel.recommendations)
        }
    }
    
    
    
    private func saveGoalToUserProfile(_ goal: String) {
        guard let profile = profiles.first else { return }
        profile.goal = goal
        do {
            try CoreDataManager.shared.container.viewContext.save()
        } catch {
            print("사용자 목표 저장 실패: \(error.localizedDescription)")
        }
    }
    
    private func loadRecommendations(goal: String) {
        guard let profile = profiles.first else { return }
        let user = UserModel(
            year: Int(profile.year),
            mbti: MBTIType(rawValue: profile.mbti ?? "") ?? .INTJ,
            priority: .운동,
            goal: goal,
            isOnboardingCompleted: profile.onboardingCompleted
        )
        Task {
            await viewModel.streamLoad(user: user)
        }
    }
}


#Preview {
    RecommendationTabView()
        .environmentObject(TabSelectionManager.shared)
}
