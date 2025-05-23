//
//  RecommendationChatGPT.swift
//  PickChal
//
//  Created by 윤태한 on 5/20/25.
//

import Foundation
import ChatGPTSwift

class RecommendationChatGPT {
    private let apiKey: String = {
        let key = ""
        return key
    }()
    private lazy var api = ChatGPTAPI(apiKey: apiKey)

    private func encodeUser(_ user: UserModel) throws -> String {
        let dict: [String: Any] = [
            "year": user.year,
            "mbti": user.mbti.rawValue,
            "priority": user.priority.rawValue,
            "routineDifficulty": user.routineDifficulty.rawValue,
            "goalDescription": user.goalDescription
        ]
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    func recommend(user: UserModel) async throws -> String {
        let userJSON = try encodeUser(user)
        let prompt = "사용자정보: \(userJSON)\n이걸 바탕으로 일일챌린지 3개를 title,description,iconName 필드를 가진 JSON 배열로 응답해주고 JSON 배열 외 다른 텍스트는 포함하지 말아줘"
        return try await api.sendMessage(text: prompt)
    }
}

//"{\"year\":user.year,\"mbti\":user.mbti.rawValue,\"interests\":~~~}"
