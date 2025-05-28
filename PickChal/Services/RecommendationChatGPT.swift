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
                "alarmTime": "09:00:00",
                "iconName": "figure.walk",
                "days": 3
              },
              {
                "id": "f0b92a40-09d2-41d0-b2ab-ff89a6f41ac8",
                "title": "물 2L 챌린지",
                "subTitle": "수분 보충으로 건강 챙기기!",
                "descriptionText": "첫날: 하루 물 1L를 마셔보세요 / 둘째 날: 하루 물 1.5L를 목표로 해보세요 / 셋째 날: 하루 2L를 달성해보세요 / 넷째 날: 하루 2L의 물을 마시고 간단한 스트레칭을 해주세요 / 다섯째 날: 물 2.5L의 물을 마시고 스트레칭으로 하루를 마무리해보세요",
                "category": "건강",
                "alarmTime": "08:00:00",
                "iconName": "drop.fill",
                "days": 5
              },
              {
                "id": "d8a0f0c6-47de-463f-9f4c-0a8b5d7518f7",
                "title": "일기 쓰기 챌린지",
                "subTitle": "하루를 되돌아보며 마음 정리",
                "descriptionText": "첫날: 오늘의 기분과 간단한 메모를 남겨보세요 / 둘째 날: 감사한 일을 한 가지 찾아보세요 / 셋째 날: 오늘 있었던 작은 행복을 적어보세요 / 넷째 날: 나만의 목표를 적어보세요 / 다섯째 날: 하루를 마무리하며 느낀 점을 정리해보세요 / 여섯째 날: 앞으로의 계획을 생각해보세요 / 일곱째 날: 일주일간의 소감을 정리해보세요",
                "category": "자기계발",
                "alarmTime": "21:00:00",
                "iconName": "pencil.and.outline",
                "days": 7
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
