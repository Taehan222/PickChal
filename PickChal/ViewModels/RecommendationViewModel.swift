//
//  RecommendationViewModel.swift
//  PickChal
//
//  Created by 윤태한 on 5/20/25.
//

import Foundation
import SwiftUI

@MainActor
class RecommendationViewModel: ObservableObject {
    @Published var recommendations: [RecommendationModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var containsInvalidRecommendation: Bool = false
    @Published var isUsageLimitExceeded: Bool = false // API 사용량 제한 초과 여부

    private let chatService = RecommendationChatGPT()
    private var streamingTask: Task<Void, Never>? = nil
    private var acceptedChallengeIDs: Set<UUID> = []

    func streamLoad(user: UserModel) async {
        streamingTask?.cancel()
        
        isLoading = true
        errorMessage = nil
        recommendations = []
        containsInvalidRecommendation = false
        isUsageLimitExceeded = false

        var buffer = ""

        streamingTask = Task {
            do {
                try await chatService.streamRecommend(user: user) { [weak self] partial in
                    guard let self = self, !Task.isCancelled else {
                        return
                    }
                    
                    buffer += partial

                    while let (objectString, rest) = self.extractNextJSONObject(from: buffer) {
                        buffer = rest
                        
                        if let data = objectString.data(using: .utf8),
                           let model = try? JSONDecoder().decode(RecommendationModel.self, from: data) {

                            if model.title == "잘못된 목표입니다" {
                                self.containsInvalidRecommendation = true
                                self.streamingTask?.cancel()
                                return
                            }

                            guard !self.acceptedChallengeIDs.contains(model.id) else {
                                continue
                            }
                            self.recommendations.append(model)
                        }
                    }
                }
            } catch {
                if !Task.isCancelled {
                    if let recommendationError = error as? RecommendationError, recommendationError == .usageLimitExceeded {
                        self.isUsageLimitExceeded = true
                        self.errorMessage = recommendationError.localizedDescription
                    } else {
                        self.errorMessage = "불러오기 실패: \(error.localizedDescription)"
                    }
                }
            }
            isLoading = false
            streamingTask = nil
        }

        await streamingTask?.value
    }

    func cancelStreaming() {
        streamingTask?.cancel()
        streamingTask = nil
        isLoading = false
        errorMessage = nil
        recommendations = []
        containsInvalidRecommendation = false
        isUsageLimitExceeded = false
    }

    func acceptChallenge(_ challenge: RecommendationModel) {
        acceptedChallengeIDs.insert(challenge.id)
        recommendations.removeAll { $0.id == challenge.id }
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
