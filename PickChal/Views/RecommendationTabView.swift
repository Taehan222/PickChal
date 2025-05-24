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

    private let currentUser = UserModel(
        year: 3,
        mbti: .ENFP,
        priority: .운동,
        goal: "매일 30분 운동하기"
    )

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
                        VStack(spacing: 16) {
                            ForEach(Array(viewModel.recommendations.enumerated()), id: \.1.id) { index, rec in
                                CardView(title: rec.title,
                                         subtitle: rec.description,
                                         iconName: rec.iconName)
                                    .opacity(showCards.indices.contains(index) && showCards[index] ? 1 : 0)
                                    .offset(y: showCards.indices.contains(index) && showCards[index] ? 0 : 20)
                                    .animation(.easeOut.delay(Double(index) * 0.2), value: showCards)
                            }
                        }
                        .padding()
                        //Lazy VStack
                    }
                }
            }
            .navigationTitle("챌린지 추천")
            .task {
                await viewModel.load(user: currentUser)
                showCards = Array(repeating: false, count: viewModel.recommendations.count)
                for i in showCards.indices {
                    try? await Task.sleep(nanoseconds: 200_000_000) // 0.2초
                    showCards[i] = true
                }
            }
        }
        .background(Theme.Colors.background.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    RecommendationTabView()
}
