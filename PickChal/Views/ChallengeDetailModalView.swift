//
//  ChallengeDetailModalView.swift
//  PickChal
//
//  Created by 윤태한 on 5/25/25.
//

//import SwiftUI
//
//struct ChallengeDetailModalView: View {
//    var challenge: RecommendationModel
//    var onChallenge: () -> Void
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var saveViewModel = ChallengeSaveViewModel() // 챌린지를 coredata에 저장하는 VM
//
//    var body: some View {
//        VStack(spacing: 24) {
//            Spacer()
//
//            Image(systemName: challenge.iconName)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 60, height: 60)
//                .padding()
//
//            Text(challenge.title)
//                .font(.title)
//                .fontWeight(.bold)
//
//            Text(challenge.description)
//                .font(.body)
//                .multilineTextAlignment(.center)
//                .padding()
//
//            Spacer()
//
//            Button(action: {
//                saveViewModel.saveChallenge(from: challenge)
//                dismiss()
//                onChallenge()
//            }) {
//                Text("챌린지 도전하기")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(16)
//                    .padding(.horizontal)
//            }
//
//            Spacer(minLength: 30)
//        }
//    }
//}

import SwiftUI

struct ChallengeDetailModalView: View {
    var challenge: RecommendationModel
    var onChallenge: () -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var saveViewModel = ChallengeSaveViewModel() // 챌린지를 coredata에 저장하는 VM

    // descriptionText를 /로 나눠서 배열로 저장
    private var dailyDescriptions: [String] {
        challenge.descriptionText
            .components(separatedBy: "/")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    var body: some View {
        ScrollView {
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

                // 날짜별로 하나씩 보여주기
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(dailyDescriptions.enumerated()), id: \.0) { index, desc in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Day \(index + 1)")
                                .font(.headline)
                            Text(desc)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

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
            .padding()
        }
        .background(Theme.Colors.background.edgesIgnoringSafeArea(.all))
    }
}
