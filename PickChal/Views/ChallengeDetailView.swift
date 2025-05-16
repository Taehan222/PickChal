//
//  ChallengeDetailView.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI

struct ChallengeDetailView: View {
    let challenge: ChallengeModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(challenge.title)
                .font(.largeTitle)
                .foregroundColor(Theme.Colors.primary)
            Text(challenge.subtitle)
                .font(.body)
            
        }
        .padding()
    }
}
