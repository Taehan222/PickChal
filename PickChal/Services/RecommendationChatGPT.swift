//
//  RecommendationChatGPT.swift
//  PickChal
//
//  Created by 윤태한 on 5/20/25.
//

import Foundation
import ChatGPTSwift

class RecommendationChatGPT {
    private let apiKey: String = {
        let key = ""
        return key
    }()
    
    private lazy var api = ChatGPTAPI(apiKey: apiKey)

    private let userDefaults = UserDefaults.standard
    private let maxDailyUsage = 10 // 하루 최대 사용 횟수
    private let lastUsageResetDateKey = "lastChatGPTUsageResetDate"
    private let dailyUsageCountKey = "dailyChatGPTUsageCount"

    private func getDailyUsageCount() -> Int {
        let lastResetDate = userDefaults.object(forKey: lastUsageResetDateKey) as? Date ?? .distantPast
        let calendar = Calendar.current

        // 날짜가 바뀌면 사용 횟수를 초기화
        if !calendar.isDateInToday(lastResetDate) {
            userDefaults.set(Date(), forKey: lastUsageResetDateKey)
            userDefaults.set(0, forKey: dailyUsageCountKey)
            return 0
        } else {
            return userDefaults.integer(forKey: dailyUsageCountKey)
        }
    }

    private func incrementDailyUsageCount() {
        let currentCount = getDailyUsageCount()
        userDefaults.set(currentCount + 1, forKey: dailyUsageCountKey)
    }

    private func encodeUser(_ user: UserModel) throws -> String {
        let dict: [String: Any] = [
            "year": user.year,
            "mbti": user.mbti.rawValue,
            "priority": "-",
            "goalDescription": user.goal
        ]
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    func streamRecommend(user: UserModel, onReceive: @escaping (String) async -> Void) async throws {
        let currentUsage = getDailyUsageCount()
        if currentUsage > maxDailyUsage {
            throw RecommendationError.usageLimitExceeded
        }

        // API 호출 전 사용 횟수 증가
        incrementDailyUsageCount()

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
        
        let userJSON = try encodeUser(user)
        let prompt = """
        예시 데이터: \(mockJSON)

        당신은 챌린지 추천 전문가입니다. 아래 사용자 정보와 목표를 기반으로 사용자에게 적합한 챌린지를 추천하세요.

        - 출력은 반드시 JSON 배열 형식만으로 출력하세요.
        - JSON 외에는 절대 아무것도 출력하지 마세요. 주석, 설명, 인사말 등도 포함 금지입니다.
        - 각 챌린지 항목은 다음 필드를 포함해야 합니다:
          - id, title, subTitle, descriptionText, category, alarmTime, iconName(SF Symbol), iconColor(SF Symbol 색상 - 예: blue, orange, green 등), days(예: 3,5,7)
        - descriptionText는 다음 형식으로 작성하세요:
          - 첫날: ~ /
          - 둘째 날: ~ /
          - 셋째 날: ~ (등 점진적으로 이어짐)
        - 추천할 챌린지 수는 6개입니다.
        - alarmTime은 반드시 한국시간(KST) 기준으로 ISO8601 형식 출력 (예: "2025-06-08T09:00:00+09:00") 괄호, 설명, 텍스트는 절대 포함하지 마세요
        - category는 운동, 독서, 공부, 자기계발, 시간관리 이 5가지 항목중에 가장 어울리는 하나의 항목으로 설정해줘
        단, 아래 사용자 목표가 단어 하나이거나 추상적이거나 실현 불가능한 경우(예: '행복', '천국 가기', '아이스크림이 될래')라면,
        챌린지를 1개만 생성하고 다음 조건을 따르세요:
          - title은 반드시 '잘못된 목표입니다'로 설정
          - 나머지 필드는 비워도 되며, JSON 배열 형식은 유지해야 합니다.
        - category는 선택지 6가지 항목 중에서 챌린지에 가장 적절한 하나만 선택해서 설정하세요.선택지는 다음과 같으며, 이 외의 항목은 절대 사용하지 마세요.
          [운동, 독서, 공부, 자기계발, 시간관리, 기타]

        사용자 정보: \(userJSON)
        """
        
        for try await message in await try api.sendMessageStream(text: prompt) {
            await onReceive(message)
        }
    }
}

enum RecommendationError: Error, LocalizedError {
    case usageLimitExceeded

    var errorDescription: String? {
        switch self {
        case .usageLimitExceeded:
            return "챌린지 추천 기능 제한 횟수를 초과했습니다. 내일 다시 시도해주세요."
        }
    }
}
