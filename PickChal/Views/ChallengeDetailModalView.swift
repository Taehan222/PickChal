//
//  ChallengeDetailModalView.swift
//  PickChal
//
//  Created by 윤태한 on 5/25/25.
//

import SwiftUI

struct ChallengeDetailModalView: View {
    var challenge: RecommendationModel
    var onChallenge: () -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var saveViewModel = ChallengeSaveViewModel() // 챌린지를 coredata에 저장하는 VM

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: challenge.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding()

            Text(challenge.title)
                .font(.title)
                .fontWeight(.bold)

            Text(challenge.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            Button(action: {
                saveViewModel.saveChallenge(from: challenge)
                dismiss()
                onChallenge()
            }) {
                Text("챌린지 도전하기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
                    .padding(.horizontal)
            }

            Spacer(minLength: 30)
        }
    }
}
