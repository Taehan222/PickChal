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
                    "title": "아침 스트레칭 시작하기",
                    "description": "하루를 기분 좋게 시작하기 위해 아침에 일어나자마자 10분 간의 스트레칭을 해보세요. 유연성을 높이고 몸을 깨워주는 효과가 있습니다.",
                    "iconName": "figure.walk"
                },
                {
                    "title": "점심 산책 시간",
                    "description": "점심 식사 후에 10분 동안 산책을 통해 신선한 공기를 마시고 소화를 촉진하세요. 기분이 상쾌해지며 오후의 피로를 덜 수 있습니다.",
                    "iconName": "leaf"
                },
                {
                    "title": "저녁 홈 피트니스",
                    "description": "하루를 마무리하며 10분 동안 홈 피트니스 루틴을 진행하세요. 영상이나 앱을 활용해 유산소나 근력 운동을 통해 스트레스를 해소하고, 목표한 30분을 채울 수 있습니다.",
                    "iconName": "house.fill"
                }
            ]
            """
        return mockJSON
        
         // MARK: 원래 코드
//         let userJSON = try encodeUser(user)
//         let prompt = "사용자정보: \(userJSON)\n이걸 바탕으로 일일챌린지 3개를 title,description(구체적인 목표와 장점 설명),iconName(SF Symbol) 필드를 가진 JSON 배열로 응답해주고 JSON 배열 외 다른 텍스트는 포함하지 말아줘"
//         return try await api.sendMessage(text: prompt)
    }
}


//"{\"year\":user.year,\"mbti\":user.mbti.rawValue,\"interests\":~~~}"
