//
//  RecommendationViewModel.swift
//  PickChal
//
//  Created by 윤태한 on 5/20/25.
//

import Foundation

@MainActor
class RecommendationViewModel: ObservableObject {
    @Published var recommendations: [RecommendationModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let chatService = RecommendationChatGPT()

    private func extractJSONArray(from text: String) -> String? {
        guard let start = text.firstIndex(of: "["), let end = text.lastIndex(of: "]") else {
            return nil
        }
        return String(text[start...end])
    }

    func load(user: UserModel) async {
        isLoading = true
        errorMessage = nil
        do {
            let raw = try await chatService.recommend(user: user)
            guard let jsonArrayString = extractJSONArray(from: raw),
                  let data = jsonArrayString.data(using: .utf8) else {
                throw URLError(.cannotParseResponse)
            }
            let recs = try JSONDecoder().decode([RecommendationModel].self, from: data)
            recommendations = recs
        } catch {
            errorMessage = "추천 불러오기 실패: \(error.localizedDescription)\n응답: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
