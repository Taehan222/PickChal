//
//  OnboardingIntroView.swift
//  PickChal
//
//  Created by 조수원 on 5/25/25.
//

import SwiftUI
import UserNotifications

struct OnboardingIntroView: View {
    @StateObject var viewModel = OnboardingVM()
    @State private var showBox1 = false
    @State private var showBox2 = false
    @State private var showBox3 = false
    @State private var showArrow2 = false
    @State private var showArrow3 = false
    @State private var showNextButton = false
    @State private var navigateNext = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 60)

                Text("사용자에게 알맞는\n루틴을 추천 해줘요")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(showBox1 ? 1 : 0)
                    .scaleEffect(showBox1 ? 1 : 0.95)
                    .animation(.easeOut(duration: 0.6), value: showBox1)

                VStack(spacing: 30) {
                    if showBox1 {
                        OnboardingStepBox(
                            text: "사용자에게 알맞는 루틴을 분석해요",
                            icon: "chart.bar.fill",
                            iconColor: Color(red: 219/255, green: 196/255, blue: 240/255),
                            backgroundColor: Color(red: 255/255, green: 245/255, blue: 245/255)
                        )
                        .transition(.opacity.combined(with: .scale))
                    }

                    VStack(spacing: 20) {
                        if showArrow2 {
                            Image(systemName: "arrow.down")
                                .foregroundColor(.black)
                                .transition(.opacity.combined(with: .scale))
                        }
                        if showBox2 {
                            OnboardingStepBox(
                                text: "캘린더에 저장하여 챌린지를 완주해요",
                                icon: "calendar",
                                iconColor: Color(red: 245/255, green: 150/255, blue: 150/255),
                                backgroundColor: Color(red: 255/255, green: 245/255, blue: 245/255)
                            )
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .transition(.opacity.combined(with: .scale))

                    VStack(spacing: 20) {
                        if showArrow3 {
                            Image(systemName: "arrow.down")
                                .foregroundColor(.black)
                                .transition(.opacity.combined(with: .scale))
                        }
                        if showBox3 {
                            OnboardingStepBox(
                                text: "알람을 통해 체계적으로 루틴을 관리해요",
                                icon: "alarm",
                                iconColor: Color(red: 89/255, green: 193/255, blue: 254/255),
                                backgroundColor: Color(red: 255/255, green: 245/255, blue: 245/255)
                            )
                            .transition(.opacity.combined(with: .scale))
                            .onAppear {
                                requestNotificationPermission()
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
                }
                .padding(.top, 50)
                .animation(.easeOut(duration: 0.9), value: [showBox1, showBox2, showBox3, showArrow2, showArrow3, showNextButton])

                Spacer()

                if showNextButton {
                    NavigationLink(destination: OnboardingUserInfoView(viewModel: viewModel), isActive: $navigateNext) {
                        Button {
                            navigateNext = true
                        } label: {
                            HStack {
                                Text("다음")
                                    .font(.headline)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color(red: 250/255, green: 250/255, blue: 250/255))
                            .cornerRadius(20)
                            .padding(.horizontal, 20)
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }

                Spacer().frame(height: 40)
            }
            .onAppear {
                showIntroSequence()
            }
        }
    }

    private func showIntroSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showBox1 = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showArrow2 = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            showBox2 = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            showArrow3 = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.8) {
            showBox3 = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            withAnimation {
                showNextButton = true
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("알람 허용 요청 에러: \(error.localizedDescription)")
            } else {
                print("알람 허용 여부: \(granted)")
            }
        }
    }
}

struct OnboardingStepBox: View {
    var text: String
    var icon: String
    var iconColor: Color
    var backgroundColor: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(iconColor)
            Text(text)
                .foregroundColor(Color(red: 80/255, green: 80/255, blue: 80/255))
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
}

#Preview {
    OnboardingIntroView(viewModel: OnboardingVM())
}
