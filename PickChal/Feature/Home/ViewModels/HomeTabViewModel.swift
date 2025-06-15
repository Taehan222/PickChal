//
//  HomeTabViewModel.swift
//  PickChal
//
//  Created by 조수원 on 5/25/25.
//

import SwiftUI
import CoreData

class HomeTabViewModel: ObservableObject {
    @Published var selectedChallengeID: UUID?
    @Published var showAlert = false

    // 챌린지 완료 버튼 클릭 시 챌린지 id 저장 후 알림창 띄우기
    func showCompletionAlert(for id: UUID) {
        selectedChallengeID = id
        showAlert = true
        print("\(id) 챌린지 완료")
    }

    // coredata에서 해당 id 챌린지를 완료로 변경 후 저장
    func completeChallenge() {
        guard let id = selectedChallengeID else { return }
        let context = CoreDataManager.shared.container.viewContext
        let fetchRequest: NSFetchRequest<Challenge> = Challenge.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let result = try context.fetch(fetchRequest)
            if let challenge = result.first {
                challenge.isCompleted = true
                try context.save()
                print("챌린지 완료 상태로 변경 ")
            }
            showAlert = false
        } catch {
            print("CoreData 업데이트 실패: \(error.localizedDescription)")
        }
    }

    // 완료된 챌린지를 다시 진행 중으로 상태 변경
    func reactivateChallenge(challenge: Challenge) {
        let context = CoreDataManager.shared.container.viewContext
        challenge.isCompleted = false
        do {
            try context.save()
            print("완료된 챌린지를 진행 중인 챌린지로 상태 변경 성공")
        } catch {
            print("챌린지 상태 변경 실패: \(error.localizedDescription)")
        }
    }
}
