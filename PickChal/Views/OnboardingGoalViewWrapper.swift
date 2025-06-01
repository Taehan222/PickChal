//
//  OnboardingGoalViewWrapper.swift
//  PickChal
//
//  Created by 조수원 on 6/1/25.
//

import SwiftUI

struct OnboardingGoalViewWrapper: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showInput = false
    @State private var showBackgroundCards = false
    @State private var cardInfos: [BackgroundCardInfo] = []
    @State private var userInput: String = ""

    let onGoalEntered: (String) -> Void

    private let words: [String] = [
        "iOS 앱 개발자가 되고 싶어요", "헬스해서 몸을 만들고 싶어요", "밤 낮을 바꾸고 싶어요",
        "한달에 책 3권은 완독하고 싶어요", "마음의 안정을 찾고 싶어요",
        "외국인이랑 대화할 정도의 영어 실력을 갖고 싶어요", "하루에 물 2리터를 꾸준히 마시고 싶어요",
        "매일 명상을 실천해보고 싶어요", "더 나은 식습관을 만들고 싶어요",
        "자기 전에 일기를 써보고 싶어요", "하루에 30분씩 운동을 하고 싶어요",
        "6시에 일어나서 하루를 시작하고 싶어요", "나를 사랑하고 싶어요",
        "SNS 사용 시간을 줄이고 싶어요", "새로운 취미를 찾고 싶어요", "졸려요", "배고파요",
        "무슨 말을 더 써야할까요", "쓸 말이 이젠 없어요", "나중에 GPT로 더 뽑아야겠어요", "이 정도면 꽉 차겠죠"
    ]

    var body: some View {
        ZStack {
            ForEach(cardInfos, id: \.self) { info in
                BackgroundCardView(text: info.text, color: info.color)
                    .position(info.position)
                    .opacity(showBackgroundCards ? 1.0 : 0.0)
                    .animation(
                        Animation.easeInOut(duration: 3.0)
                            .repeatForever(autoreverses: true)
                            .delay(Double(info.index) * 0.2),
                        value: showBackgroundCards
                    )
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

                        Button("확인") {
                            onGoalEntered(userInput)
                            dismiss()
                        }
                        .disabled(userInput.isEmpty)
                        .opacity(userInput.isEmpty ? 0.4 : 1.0)
                        .padding(.top, 10)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: showInput)
                }
            }
            .frame(width: 300)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 8)
            .opacity(showInput ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 1.5), value: showInput)
            .onAppear {
                setupCardInfos()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showInput = true
                        showBackgroundCards = true
                    }
                }
            }
        }
        .background(Color.white)
        .ignoresSafeArea()
    }

    private func setupCardInfos() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        let cardWidth: CGFloat = 180
        let cardHeight: CGFloat = 50
        let horizontalPadding: CGFloat = 20
        let verticalPadding: CGFloat = 100

        var positions: [CGRect] = []
        var infos: [BackgroundCardInfo] = []

        for (index, word) in words.enumerated() {
            var position: CGPoint?
            let maxAttempts = 100

            for _ in 0..<maxAttempts {
                let x = CGFloat.random(in: horizontalPadding...(screenWidth - horizontalPadding))
                let y = CGFloat.random(in: verticalPadding...(screenHeight - verticalPadding))
                let newRect = CGRect(x: x - cardWidth/2, y: y - cardHeight/2, width: cardWidth, height: cardHeight)

                if positions.allSatisfy({ !$0.intersects(newRect) }) {
                    position = CGPoint(x: x, y: y)
                    positions.append(newRect)
                    break
                }
            }

            if position == nil {
                let fallbackX = CGFloat.random(in: horizontalPadding...(screenWidth - horizontalPadding))
                let fallbackY = CGFloat.random(in: verticalPadding...(screenHeight - verticalPadding))
                position = CGPoint(x: fallbackX, y: fallbackY)
            }

            let pastelColor = Color(
                hue: Double.random(in: 0...1),
                saturation: Double.random(in: 0.2...0.4),
                brightness: 1.0
            )

            infos.append(BackgroundCardInfo(index: index, text: word, position: position!, color: pastelColor))
        }

        self.cardInfos = infos
    }
}

#Preview {
    OnboardingGoalViewWrapper { goal in
        print("입력된 목표: \(goal)")
    }
}
