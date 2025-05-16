//
//  ChallengeModel.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//


import Foundation

struct ChallengeModel: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let totalCount: Int
    let completedCount: Int
    var progress: CGFloat {
        guard totalCount > 0 else { return 0 }
        return CGFloat(completedCount) / CGFloat(totalCount)
    }
}
