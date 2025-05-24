//
//  UserModel.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import Foundation

// MARK: UserProfile Model
struct UserModel {
    var year: Int
    var mbti: MBTIType
    var priority: ChallengeCategory
    var goal: String
}

// MARK: MBTI
enum MBTIType: String, CaseIterable, Identifiable {
    case ENFP, ENFJ, ENTP, ENTJ
    case ESFP, ESFJ, ESTP, ESTJ
    case INFP, INFJ, INTP, INTJ
    case ISFP, ISFJ, ISTP, ISTJ

    var id: String { self.rawValue }
}

enum ChallengeCategory: String, CaseIterable, Identifiable {
    case 운동, 독서, 공부, 자기계발, 시간관리
    var id: String { rawValue }
}

// MARK: 챌린지 모델
struct ChallengeModel: Identifiable {
    var id: UUID
    var title: String
    var subTitle: String
    var description: String
    var category: String
    var startDate: Date
    var endDate: Date
    var totalCount: Int
    var createdAt: Date
    var alarmTime: Date
    var isCompleted: Bool = false 
}

// MARK: 챌린지 로그 모델
struct ChallengeLogModel: Identifiable {
    var id: UUID
    var date: Date
    var completed: Bool
    var challengeID: UUID
}

// MARK: 챌린지 추천 모델
struct RecommendationModel: Identifiable, Decodable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String

    private enum CodingKeys: String, CodingKey {
        case title, description, iconName, id
    }

    init(id: UUID = UUID(), title: String, description: String, iconName: String) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try c.decode(String.self, forKey: .title)
        self.description = try c.decode(String.self, forKey: .description)
        self.iconName = try c.decode(String.self, forKey: .iconName)
        self.id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
    }
}
