//
//  ChallengesViewModel.swift
//  PickChal
//
//  Created by 조수원 on 5/24/25.
//

import Foundation
import CoreData

class ChallengeViewModel: ObservableObject {
    @Published var challenges: [ChallengeModel] = []

    // 진행 중인 챌린지를 완료 상태로 변경
    func completeChallenge(id: UUID) {
        let context = CoreDataManager.shared.container.viewContext
        let request: NSFetchRequest<Challenge> = Challenge.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let challenge = try context.fetch(request).first {
                challenge.isCompleted = true
                try context.save()
                print("진행 중인 챌린지 완료 상태로 변경 성공")
            }
        } catch {
            print("진행 중인 챌린지 완료 상태 변경 실패: \(error.localizedDescription)")
        }
    }
    
    // 완료된 챌린지를 진행 중인 챌린지로 상태 변경
    func goingChallenge(id: UUID) {
        let context = CoreDataManager.shared.container.viewContext
        let request: NSFetchRequest<Challenge> = Challenge.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let challenge = try context.fetch(request).first {
                challenge.isCompleted = false
                try context.save()
                print("완료된 챌린지를 진행 중인 챌린지로 상태 변경 성공")
            }
        } catch {
            print("완료된 챌린지 진행 중으로 상태 변경 실패: \(error.localizedDescription)")
        }
    }
}
