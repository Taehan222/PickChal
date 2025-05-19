//
//  CoreDataManager.swift
//  PickChal
//
//  Created by 조수원 on 5/19/25.
//

import Foundation
import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "PickChal")
        container.loadPersistentStores { (storeDescription, error)in
            if let error = error as NSError? {
                fatalError("CoreData 로딩 실패: \(error.localizedDescription), \(error.userInfo)")
            }
        }
    }
    
    // MARK: context에 변경 사항이 생기면 자동 저장
    func saveContext() {
        let context = CoreDataManager.shared.container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("CoreData 저장 완료")
            } catch {
                let nserror = error as NSError
                fatalError("CoreData 저장 실패: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
// MARK: 사용자 정보 저장, 불러오기, 업데이트
    
    // MARK: 사용자 정보 저장
    func saveUserProfile(input: UserModel) {
        let context = CoreDataManager.shared.container.viewContext
        
        let user = UserProfile(context: context)
        user.id = UUID()
        user.year = Int16(input.year)
        user.mbti = input.mbti.rawValue
        user.priority = input.priority.rawValue
        user.difficulty = input.routineDifficulty.rawValue
        user.goal = input.goalDescription
        user.createdAt = Date()

        saveContext()
    }

    // MARK: 사용자 정보 불러오기
    func fetchUserProfile() -> UserModel? {
        guard let entity = fetchUserProfileEntity() else {
            print("사용자 정보가 없습니다.")
            return nil
        }

        return UserModel(
            year: Int(entity.year),
            mbti: MBTIType(rawValue: entity.mbti ?? "") ?? .INTJ,
            interests: [],
            priority: ChallengePriority(rawValue: entity.priority ?? "") ?? .건강,
            routineDifficulty: RoutineDifficulty(rawValue: entity.difficulty ?? "") ?? .tenMinutes,
            goalDescription: entity.goal ?? ""
        )
    }
    
    // MARK: 사용자 정보 조회
    func fetchUserProfileEntity() -> UserProfile? {
        let context = CoreDataManager.shared.container.viewContext
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            do {
                return try context.fetch(request).first
            } catch {
                print("사용자 정보 불러오기 실패: \(error.localizedDescription)")
                return nil
            }
        }
    
    // MARK: 사용자 정보 업데이트
    func updateUserProfile(input: UserModel) {
        let context = container.viewContext
        let log = Challenge(context: context)
        guard let user = fetchUserProfileEntity() else {
            print("사용자 정보 없음 업데이트 불가")
            return
        }
        
        user.id = UUID()
        user.mbti = input.mbti.rawValue
        user.priority = input.priority.rawValue
        user.difficulty = input.routineDifficulty.rawValue
        user.goal = input.goalDescription
        
        clearUserInterests()
        saveUserInterests(input.interests)
        
        saveContext()
    }
    
// MARK: 사용자 관심사 저장, 불러오기, 삭제
    
    // MARK: 사용자 관심사 저장
    func saveUserInterests(_ interests: [InterestType]) {
        let context = container.viewContext
        
        guard let user = fetchUserProfileEntity() else {
            print("사용자 정보 없음 관심사 저장 실패")
            return
        }
        
        for interest in interests {
            let interestEntity = Interest(context: context)
            interestEntity.id = UUID()
            interestEntity.interestName = interest.rawValue
            interestEntity.user = user
        }
    }
    
    // MARK: 사용자 관심사 불러오기
    func fetchUserInterests() -> [Interest] {
        let context = container.viewContext
        
        guard let user = fetchUserProfileEntity() else {
            print("사용자 정보 없음 관심사 불러오기 실패")
            return []
        }
        let request: NSFetchRequest<Interest> = Interest.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        
        do {
            return try context.fetch(request)
        } catch {
            print("관심사 불러오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: 사용자 관심사 삭제
    func clearUserInterests() {
        let context = container.viewContext
        let interests = fetchUserInterests()
        for interest in interests {
            context.delete(interest)
        }
    }
    
// MARK: 챌린지 기록 저장, 불러오기, 삭제
    
    // MARK: 챌린지 기록 저장
    func logChallengeCompletion(title: String, date: Date, completed: Bool) {
        let context = container.viewContext
        
        guard fetchUserProfileEntity() != nil else {
            print("사용자 정보 없음 챌린지 기록 저장 실패")
            return
        }
        
        let log = ChallengeLog(context: context)
        log.id = UUID()
        log.challengeTitle = title
        log.date = date
        log.completed = completed
        
        saveContext()
    }
    
    // MARK: 챌린지 기록 불러오기
    func fetchLogs(for date: Date) -> [ChallengeLog] {
        let context = container.viewContext
        let request: NSFetchRequest<ChallengeLog> = ChallengeLog.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            return try context.fetch(request)
        } catch {
            print("챌린지 로그 불러오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: 챌린지 기록 삭제하기
    func deleteChallengeLog(_ log: ChallengeLog) {
        let context = container.viewContext
        context.delete(log)
        saveContext()
    }
}
