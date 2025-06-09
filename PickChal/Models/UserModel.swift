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
    var isOnboardingCompleted: Bool
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
    var title: String // 제목
    var subTitle: String // 부제목
    var descriptionText: String // 챌린지 설명
    var category: String // 카테고리
    var startDate: Date // 시작한 날
    var endDate: Date // 끝나는 날
    var totalCount: Int // 
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
    var descriptionText: String
}

// MARK: 챌린지 추천 모델
struct RecommendationModel: Identifiable, Decodable, Equatable {
    let id: UUID
    let title: String
    let descriptionText: String
    let iconName: String
    let iconColor: String?
    let category: String
    let alarmTime: Date?
    

    private enum CodingKeys: String, CodingKey {
        case title, descriptionText, iconName, iconColor, id, category, alarmTime
    }

    init(
        id: UUID = UUID(),
        title: String,
        descriptionText: String,
        iconName: String,
        iconColor: String? = nil,
        category: String,
        alarmTime: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.descriptionText = descriptionText
        self.iconName = iconName
        self.iconColor = iconColor
        self.category = category
        self.alarmTime = alarmTime
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try c.decode(String.self, forKey: .title)
        self.descriptionText = try c.decode(String.self, forKey: .descriptionText)
        self.iconName = try c.decode(String.self, forKey: .iconName)
        self.iconColor = try? c.decode(String.self, forKey: .iconColor)
        self.id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        self.category = try c.decode(String.self, forKey: .category)
        if let timeString = try? c.decode(String.self, forKey: .alarmTime) {
                let formatter = ISO8601DateFormatter()
                if let parsedDate = formatter.date(from: timeString) {
                    self.alarmTime = parsedDate
                } else {
                    //print("alarmTime 문자열 파싱 실패: \(timeString)")
                    self.alarmTime = nil
                }
            } else {
                self.alarmTime = nil
            }
    }
}
