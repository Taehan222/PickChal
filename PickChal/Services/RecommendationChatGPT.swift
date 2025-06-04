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
//            "priority": user.priority.rawValue,
            "priority": "-",
            "goalDescription": user.goal
        ]
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
    func recommend(user: UserModel) async throws -> String {
        // 임시 더미데이터
        let mockJSON = """
            [
              {
                "id": "b7f0a7bc-52d0-4b0a-bc6b-28ef3947d706(예시)",
                "title": "아침 스트레칭 루틴(예시)",
                "subTitle": "하루를 상쾌하게 시작하세요!(예시)",
                "descriptionText": "첫날: (예시) / 둘째 날: (예시) / 셋째 날: (예시)",
                "category": "운동(예시)",
                "alarmTime": "2025-06-01T09:00:00+09:00(예시)",
                "iconName": "figure.walk(예시)",
                "iconColor": "green(예시)",
                "days": 3(예시)
              }
            ]
            """
        // return mockJSON
        
        let userJSON = try encodeUser(user)
        let prompt = """
             예시데이터: \(mockJSON)
             위의 예시 데이터처럼 id, title, subTitle, descriptionText, category, alarmTime, iconName(SF Symbol), iconColor(SF Symbol 색상 - 예: blue, orange, green 등), days(예: 3,5,7) 필드를 가진 챌린지를 사용자정보: \(userJSON) 기반으로 목표에 관련된 챌린지만 10개 추천해서 JSON 배열로 순수하게 출력해줘.
             JSON 배열 외 다른 텍스트는 절대 포함하지 마세요.
             descriptionText는 '첫날:', '둘째 날:' 형식으로 작성하고 점진적으로 이어지게 해줘.
             """
        
        print(prompt)
        return try await api.sendMessage(text: prompt)
    }
}
