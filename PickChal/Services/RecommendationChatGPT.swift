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
                "id": "b7f0a7bc-52d0-4b0a-bc6b-28ef3947d706",
                "title": "아침 스트레칭 루틴",
                "subTitle": "하루를 상쾌하게 시작하세요!",
                "descriptionText": "첫날: 간단한 목과 어깨 스트레칭으로 시작해보세요 / 둘째 날: 전신 스트레칭으로 몸 전체를 풀어주세요 / 셋째 날: 깊은 호흡과 함께 10분간의 스트레칭으로 마무리해보세요",
                "category": "운동",
                "alarmTime": "2025-06-01T09:00:00+09:00"
                "iconName": "figure.walk",
                "days": 3
              }
            ]
            """
//        return mockJSON
        
         // MARK: 원래 코드
         let userJSON = try encodeUser(user)
         let prompt = "예시데이터: \(mockJSON) 위의 예시 데이터처럼 id,title,subTitle,descriptionText,category,alarmTime,iconName(SF Symbol),days 필드를 가진 챌린지를 사용자정보: \(userJSON) 기반으로 챌린지 3개를 JSON 배열로 순수하게 출력해줘. JSON 배열 외 다른 텍스트는 절대 포함하지 마세요. descriptionText는 첫날, 둘째 날, 이런식으로 날로만 해주고 진행이 점진적이게 이어지게 해줘"
         return try await api.sendMessage(text: prompt)
    }
}
