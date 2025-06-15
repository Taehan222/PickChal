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
    @StateObject private var saveViewModel = ChallengeSaveViewModel()
    @EnvironmentObject var themeManager: ThemeManager

    private var dailyDescriptions: [String] {
        challenge.descriptionText
            .components(separatedBy: "/")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: challenge.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .padding()
                        .foregroundColor(Color.from(name: challenge.iconColor))
                   

                    Text(challenge.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(dailyDescriptions.enumerated()), id: \.0) { index, desc in
                            VStack(alignment: .leading, spacing: 4) {
                                
                                Text("Day \(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(desc)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.currentTheme.accentColor, lineWidth: 3)
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: {
                        //print(challenge.alarmTime)
                        saveViewModel.saveChallenge(from: challenge)
                        dismiss()
                        onChallenge()
                    }) {
                        Text("챌린지 도전하기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.currentTheme.accentColor)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }

                    Spacer(minLength: 30)
                }
                .padding()
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
