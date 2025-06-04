//
//  OnboardingUserInfoView.swift
//  PickChal
//
//  Created by 조수원 on 5/25/25.
//

import SwiftUI

struct OnboardingUserInfoView: View {
    @ObservedObject var viewModel: OnboardingVM
    @State private var selectedGender: String? = nil
    @State private var selectedAgeGroup: String? = nil
    @State private var navigateNext = false

    let ageGroups: [(title: String, subtitle: String)] = [
        ("20↓", "20대 미만"),
        ("20", "20대"),
        ("30", "30대"),
        ("40", "40대"),
        ("50", "50대"),
        ("60↑", "60대 이상")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                VStack(spacing: 4) {
                    Text("성별/연령대를 알려주세요!")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.primary)

                    Text("사용자에게 알맞는 챌린지를 추천해드릴 수 있어요")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                HStack(spacing: 20) {
                    genderButton("여성", imageName: "여자")
                    genderButton("남성", imageName: "남자")
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(ageGroups, id: \.title) { group in
                        Button(action: {
                            selectedAgeGroup = group.title
                            print("선택된 연령대: \(group.title)")
                        }) {
                            VStack(spacing: 4) {
                                Circle()
                                    .stroke(selectedAgeGroup == group.title ? Color.blue : Color.gray.opacity(0.7), lineWidth: 1)
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text(group.title)
                                            .foregroundColor(selectedAgeGroup == group.title ? Color.blue : .secondary)
                                            .font(.system(size: 30, weight: .thin))
                                    )
                                Text(group.subtitle)
                                    .foregroundColor(selectedAgeGroup == group.title ? Color.blue : .secondary)
                                    .font(.system(size: 12))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                Button(action: {
                    print(" 성별: \(selectedGender ?? "없음"), 연령대: \(selectedAgeGroup ?? "없음")")
                    navigateNext = true
                }) {
                    HStack {
                        Text("다음")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            .blur(radius: 0.5)
                    )
                    .padding(.horizontal, 20)
                }
                .disabled(!(selectedGender != nil && selectedAgeGroup != nil))
                .opacity(selectedGender != nil && selectedAgeGroup != nil ? 1 : 0)
                .padding(.bottom, 40)
            }
            .frame(maxHeight: .infinity)
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationDestination(
                isPresented: $navigateNext,
                destination: { MBTIRadioButtonView(viewModel: viewModel) }
            )
        }
    }

    private func genderButton(_ gender: String, imageName: String) -> some View {
        Button(action: {
            selectedGender = gender
            print("선택된 성별: \(gender)")
        }) {
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemFill))
                    .blur(radius: 2)
                    .allowsHitTesting(false)

                Image(imageName)
                    .resizable()
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(selectedGender == gender ? Color.blue : Color.primary.opacity(0.3), lineWidth: 0.5)
                    )
            }
            .frame(width: 170, height: 170)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingUserInfoView(viewModel: OnboardingVM())
}
