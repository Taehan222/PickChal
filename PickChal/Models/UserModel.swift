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
    var interests: [InterestType]
    var priority: ChallengePriority
    var routineDifficulty: RoutineDifficulty
    var goalDescription: String
}

// MARK: MBTI
enum MBTIType: String, CaseIterable, Identifiable {
    case ENFP, ENFJ, ENTP, ENTJ
    case ESFP, ESFJ, ESTP, ESTJ
    case INFP, INFJ, INTP, INTJ
    case ISFP, ISFJ, ISTP, ISTJ

    var id: String { self.rawValue }
}

// MARK: 관심사
enum InterestType: String, CaseIterable, Identifiable {
    case 운동
    case 독서
    case 공부
    case 자기계발

    var id: String { self.rawValue }
}

// MARK: 챌린지로 얻고 싶은 것
enum ChallengePriority: String, CaseIterable, Identifiable {
    case 시간관리
    case 마음의여유
    case 건강
    case 동기부여
    case 시험준비

    var id: String { self.rawValue }
}

// MARK: 챌린지 난이도
enum RoutineDifficulty: String, CaseIterable, Identifiable {
    case tenMinutes = "10분 루틴"
    case thirtyMinutes = "30분 루틴"
    case oneHour = "1시간 루틴"

    var id: String { self.rawValue }
}

// MARK: 임시 챌린지 모델
struct ChallengeModel: Identifiable {
    var id: UUID
    var title: String
    var subtitle: String
    var totalCount: Int
    var completedCount: Int
    var date: Date
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
