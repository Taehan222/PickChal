//
//  CoreDataManager.swift
//  PickChal
//
//  Created by 조수원 on 5/24/25.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }
    
    private init() {
        container = NSPersistentContainer(name: "PickChal")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("CoreData 로딩 실패: \(error), \(error.userInfo)")
            }
        }
    }
    
    private func saveDate() throws {
        if context.hasChanges {
            try context.save()
        }
    }

// MARK: 사용자 정보
    
    // 사용자 정보 저장
    func saveUserProfile(input: UserModel) throws {
        let user = UserProfile(context: context)
        user.id = UUID()
        user.year = Int16(input.year)
        user.mbti = input.mbti.rawValue
        user.goal = input.goal
        try saveDate()
    }
    
    // 사용자 정보 불러오기
    func fetchUserProfile() throws -> UserProfile? {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        return try context.fetch(request).first
    }
    
    // 사용자 정보 업데이트
    func updateUserProfile(input: UserModel) throws {
        guard let user = try fetchUserProfile() else { return }
        user.year = Int16(input.year)
        user.mbti = input.mbti.rawValue
        user.goal = input.goal
        try saveDate()
    }
    
// MARK: 챌린지
    
    // 챌린지 저장
    func saveChallenge(for user: UserProfile, challenge: ChallengeModel) throws {
        let save = Challenge(context: context)
        save.id = challenge.id
        save.title = challenge.title
        save.startDate = challenge.startDate
        save.endDate = challenge.endDate
        save.totalCount = Int16(challenge.totalCount)
        save.createdAt = challenge.createdAt
        save.alarmTime = challenge.alarmTime
        save.user = user
        try saveDate()
    }
    
    // 챌린지 불러오기
    func fetchChallenge(for user: UserProfile) throws -> [Challenge] {
        let request: NSFetchRequest<Challenge> = Challenge.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        return try context.fetch(request)
    }
    
    // 챌린지 업데이트
    func updateChallenge(for challenge: Challenge, with model: ChallengeModel) throws {
        challenge.title = model.title
        challenge.startDate = model.startDate
        challenge.endDate = model.endDate
        challenge.totalCount = Int16(model.totalCount)
        challenge.alarmTime = model.alarmTime
        try saveDate()
    }
    
    // 챌린지 삭제
    func deleteChallenge(for challenge: Challenge) throws {
        context.delete(challenge)
        try saveDate()
    }
    
// MARK: 날짜별 챌린지 기록
    
    // 챌린지 기록 저장
    func logChallenge(for challenge: Challenge, on date: Date, completed: Bool) throws {
        let log = ChallengeLog(context: context)
        log.id = UUID()
        log.date = date
        log.completed = completed
        log.challenge = challenge
        try saveDate()
    }
    
    // 특정 챌린지에 대한 전체 기록 불러오기
    func fetchLogs(for challenge: Challenge) throws -> [ChallengeLog] {
        let request: NSFetchRequest<ChallengeLog> = ChallengeLog.fetchRequest()
        request.predicate = NSPredicate(format: "challenge == %@", challenge)
        return try context.fetch(request)
    }
    
    // 특정 날짜의 전체 챌린지 기록 불러오기
    func fetchLogs(for date: Date) throws -> [ChallengeLog] {
        let request: NSFetchRequest<ChallengeLog> = ChallengeLog.fetchRequest()
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        return try context.fetch(request)
    }
    
    // 챌린지 삭제
    func deleteLog(log: ChallengeLog) throws {
        context.delete(log)
        try saveDate()
    }
}
