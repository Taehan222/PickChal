//
//  OnboardingGoalView.swift
//  PickChal
//
//  Created by 조수원 on 5/25/25.
//

import SwiftUI

struct OnboardingGoalView: View {
    @ObservedObject var viewModel: OnboardingVM
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    private let words: [String] = [
        "iOS 앱 개발자가 되고 싶어요", "헬스해서 몸을 만들고 싶어요", "밤 낮을 바꾸고 싶어요",
        "졸려요", "한달에 책 3권은 완독하고 싶어요", "마음의 안정을 찾고 싶어요",
        "외국인이랑 대화할 정도의 영어 실력을 갖고 싶어요", "하루에 물 2리터를 꾸준히 마시고 싶어요", "매일 명상을 실천해보고 싶어요",
        "더 나은 식습관을 만들고 싶어요", "자기 전에 일기를 써보고 싶어요", "하루에 30분씩 운동을 하고 싶어요",
        "6시에 일어나서 하루를 시작하고 싶어요", "나를 사랑하고 싶어요",
        "SNS 사용 시간을 줄이고 싶어요", "새로운 취미를 찾고 싶어요"
    ]

    @State private var userInput: String = ""
    @State private var showInput: Bool = false

    var body: some View {
        ZStack {
            TimelineView(.animation) { _ in
                ZStack {
                    ForEach(0..<16, id: \.self) { index in
                        let text = words[index % words.count]
                        MovingWordView(text: text, yIndex: index)
                    }
                }
            }

            VStack(spacing: 20) {
                Text("당신은 무엇을 이루고 싶나요?")
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                if showInput {
                    VStack(spacing: 16) {
                        TextField("이루고 싶은 것을 입력해보세요", text: $userInput)
                            .padding()
                            .frame(width: 260)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)

                        Button(action: {
                            viewModel.goal = userInput
                            viewModel.saveUserProfile()

                            do {
                                try CoreDataManager.shared.onboardingCompleted()
                                print("온보딩 사용자 정보 CoreData 저장 완료")
                            } catch {
                                print("온보딩 사용자 정보 CoreData 저장 실패: \(error.localizedDescription)")
                            }

                            onboardingCompleted = true
                        }) {
                            Text("확인")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(width: 100, height: 40)
                                .background(userInput.isEmpty ? Color.clear : Color.gray.opacity(0.7))
                                .cornerRadius(10)
                        }
                        .disabled(userInput.isEmpty)
                        .opacity(userInput.isEmpty ? 0.4 : 1.0)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: showInput)
                }
            }
            .frame(width: 300)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.4), radius: 6, x: 0, y: 4)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        showInput = true
                    }
                }
            }
        }
    }
}

struct MovingWordView: View {
    let text: String
    let yIndex: Int
    private let screen = UIScreen.main.bounds

    @State private var xOffset: CGFloat = UIScreen.main.bounds.width + CGFloat.random(in: 0...200)
    private let fontSize: CGFloat = CGFloat.random(in: 15...30)
    private let opacity: Double = Double.random(in: 0.2...0.5)
    private let color: Color = Color(
        hue: Double.random(in: 0...1),
        saturation: Double.random(in: 0.3...0.8),
        brightness: Double.random(in: 0.8...1.0)
    )
    private let duration: Double = Double.random(in: 5...10)

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .medium))
            .foregroundColor(color.opacity(opacity))
            .offset(x: xOffset, y: yPosition())
            .onAppear {
                animate()
            }
    }

    private func yPosition() -> CGFloat {
        let spacing: CGFloat = 36
        let total = spacing * 16
        let base = -total / 2
        return base + spacing * CGFloat(yIndex)
    }

    private func animate() {
        withAnimation(.linear(duration: duration)) {
            xOffset = -screen.width - 200
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            xOffset = screen.width + CGFloat.random(in: 0...200)
            animate()
        }
    }
}

#Preview {
    OnboardingGoalView(viewModel: OnboardingVM())
        .environmentObject(RecommendationViewModel())
}
