import Foundation

class RecommendationAlan {
    private let clientID = "72662b30-383a-4a0c-b07d-e24fc59322c9"

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
        let userJSON = try encodeUser(user)

        let prompt = """
        당신은 챌린지 추천 전문가입니다. 아래 사용자 정보를 기반으로 적절한 7일 챌린지를 추천해 주세요.

        - 출력은 반드시 JSON 배열 형식만으로 출력하세요.
        - 각 항목은 다음 필드를 포함해야 합니다:
          - id, title, subTitle, descriptionText, category, alarmTime, iconName, iconColor, days
        - descriptionText는 다음 형식으로 작성하세요:
          - 첫날: ~ /
          - 둘째 날: ~ /
          - 셋째 날: ~ 등 점진적으로 이어지게 작성
        - 추천할 챌린지 수는 총 6개입니다.
        - category는 운동, 독서, 공부, 자기계발, 시간관리 중 하나로 선택하세요.
        - alarmTime은 반드시 ISO8601 +09:00 형식으로 출력하세요 (예: "2025-06-08T09:00:00+09:00")

        사용자 정보:
        \(userJSON)
        """

        try await requestAlan(content: prompt, onReceive: onReceive)
    }

   
    private func requestAlan(content: String, onReceive: @escaping (String) async -> Void) async throws {
        var components = URLComponents(string: "https://kdt-api-function.azurewebsites.net/api/v1/question")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "content", value: content)
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? String else {
            await onReceive("응답 파싱 실패 또는 content 누락")
            return
        }

        await onReceive(content)
    }

   
    func resetAlanState() {
        guard let url = URL(string: "https://kdt-api-function.azurewebsites.net/api/v1/reset-state") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["client_id": clientID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request).resume()
    }
}
