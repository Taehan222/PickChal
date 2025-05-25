//
//  OnboardingIntroView.swift
//  PickChal
//
//  Created by 조수원 on 5/25/25.
//

import SwiftUI

struct OnboardingIntroView: View {
    @ObservedObject var viewModel: OnboardingVM
    @State private var showBox1 = false
    @State private var showBox2 = false
    @State private var showBox3 = false
    @State private var navigateNext = false
    @State private var showNextButton = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 40)

                Text("사용자에게 알맞는\n루틴을 추천 해줘요")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)

                VStack(spacing: 25) {
                    if showBox1 {
                        OnboardingStepBox(text: "사용자에게 알맞는 루틴을 분석해요")
                            .transition(.opacity.combined(with: .scale))
                    }

                    if showBox2 {
                        VStack(spacing: 20) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                            OnboardingStepBox(text: "캘린더에 저장하여\n챌린지를 완주해요")
                                .transition(.opacity.combined(with: .scale))
                        }
                    }

                    if showBox3 {
                        VStack(spacing: 20) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                            OnboardingStepBox(text: "알람을 통해\n체계적으로 루틴을 관리해요")
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                }
                .animation(.easeOut(duration: 0.5), value: [showBox1, showBox2, showBox3])
                .padding(.top, 50)

                Spacer()

                if showNextButton {
                    Button {
                        navigateNext = true
                    } label: {
                        Text("다음")
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray, lineWidth: 1.5)
                            )
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .onAppear {
                showStepBoxesWithDelay()
            }
            .navigationDestination(isPresented: $navigateNext) {
                OnboardingUserInfoView(viewModel: viewModel)
            }
        }
    }

    func showStepBoxesWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { showBox1 = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showBox2 = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showBox3 = true
            showNextButton = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            NotificationManager.shared.requestPermission()
        }
    }
}

struct OnboardingStepBox: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.body)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
            .padding(.horizontal, 32)
    }
}

#Preview {
    OnboardingIntroView(viewModel: OnboardingVM())
}
