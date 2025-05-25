//
//  OnboardingUserInfoView.swift
//  PickChal
//
//  Created by 조수원 on 5/25/25.
//

import SwiftUI

struct OnboardingUserInfoView: View {
    @ObservedObject var viewModel: OnboardingVM
    @State private var navigateNext = false

    private let years: [Int] = Array((1980...2010).reversed())
    private let mbtiList: [MBTIType] = MBTIType.allCases

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 60)

            Text("당신은 어떤 사람인가요?")
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Picker(selection: $viewModel.year, label: Text("\(viewModel.year)년생")) {
                ForEach(years, id: \.self) { year in
                    Text("\(String(year))년생")
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 140)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                spacing: 16
            ) {
                ForEach(mbtiList, id: \.self) { mbti in
                    Button(action: {
                        viewModel.mbti = mbti
                    }) {
                        Text(mbti.rawValue)
                            .foregroundColor(.black)
                            .frame(minWidth: 60, minHeight: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.mbti == mbti ? Color.red.opacity(0.2) : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(viewModel.mbti == mbti ? Color.red.opacity(0.2) : Color.gray, lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            Button {
                navigateNext = true
            } label: {
                Text("다음")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 1))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .disabled(viewModel.mbti == nil)
        }
        .navigationDestination(isPresented: $navigateNext) {
            OnboardingGoalView(viewModel: viewModel)
        }
    }
}

#Preview {
    OnboardingUserInfoView(viewModel: OnboardingVM())
}
