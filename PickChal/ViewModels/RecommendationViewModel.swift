//
//  RecommendationViewModel.swift
//  PickChal
//
//  Created by 윤태한 on 5/20/25.
//

import Foundation
import SwiftUI

@MainActor
class RecommendationViewModel: ObservableObject {
    @Published var recommendations: [RecommendationModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let chatService = RecommendationChatGPT()

    func streamLoad(user: UserModel) async {
        isLoading = true
        errorMessage = nil
        recommendations = []

        var buffer = ""

        do {
            try await chatService.streamRecommend(user: user) { partial in
                buffer += partial

                while let (objectString, rest) = self.extractNextJSONObject(from: buffer) {
                    buffer = rest
                    if let data = objectString.data(using: .utf8),
                       let model = try? JSONDecoder().decode(RecommendationModel.self, from: data) {
                        self.recommendations.append(model)
                    }
                }
            }
        } catch {
            self.errorMessage = "불러오기 실패: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func extractNextJSONObject(from text: String) -> (String, String)? {
        guard let startIndex = text.firstIndex(of: "{"),
              let endIndex = text[startIndex...].firstIndex(of: "}") else {
            return nil
        }

        let objectText = String(text[startIndex...endIndex])
        let remainingText = String(text[text.index(after: endIndex)...])
        return (objectText, remainingText)
    }
}
