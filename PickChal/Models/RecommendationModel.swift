//
//  RecommendationModel.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import Foundation
import SwiftUI

struct RecommendationModel: Identifiable {
    let id: UUID = UUID()
    let title: String
    let description: String
    let iconName: String
}
