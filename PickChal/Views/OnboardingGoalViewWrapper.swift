//
//  OnboardingGoalViewWrapper.swift
//  PickChal
//
//  Created by 조수원 on 6/1/25.
//

import SwiftUI

struct OnboardingGoalViewWrapper: View {
    @Binding var isPresented: Bool
    @State private var showInput = false
    @State private var cardInfos: [BackgroundCardInfo] = []
    @State private var userInput: String = ""

    let onGoalEntered: (String) -> Void

    private let words: [String] = [
        "iOS 앱 개발자가 되고 싶어요", "헬스해서 몸을 만들고 싶어요",
        "한달에 책 3권은 완독하고 싶어요", "마음의 안정을 찾고 싶어요",
        "영어 회화를 잘하고 싶어요", "하루에 물 2리터를 꾸준히 마시고 싶어요",
        "매일 명상을 실천해보고 싶어요", "더 나은 식습관을 만들고 싶어요",
        "자기 전에 일기를 써보고 싶어요", "하루에 30분씩 운동을 하고 싶어요",
        "6시에 일어나서 하루를 시작하고 싶어요", "SNS 사용 시간을 줄이고 싶어요",
        "새로운 취미를 찾고 싶어요", "미라클 모닝을 실천하고 싶어요", "피부가 좋아지는 습관을 만들고 싶어요"
    ]

    var body: some View {
        ZStack {
            ForEach(cardInfos, id: \.self) { info in
                BackgroundCardView(text: info.text, color: info.color)
                    .position(info.position)
                    .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: info.position)
            }

            VStack(spacing: 20) {
                Text("당신은 무엇을 이루고 싶나요?")
                    .font(.headline)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)

                if showInput {
                    VStack(spacing: 16) {
                        ZStack(alignment: .leading) {
                            if userInput.isEmpty {
                                Text("이루고 싶은 것을 입력해보세요")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 12)
                            }

                            TextField("", text: $userInput)
                                .padding()
                                .frame(width: 260)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                                .foregroundColor(.black)
                                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                        }

                        Button("확인") {
                            onGoalEntered(userInput)
                            isPresented = false
                        }
                        .disabled(userInput.isEmpty)
                        .opacity(userInput.isEmpty ? 0.4 : 1.0)
                        .padding(.top, 10)
                    }
                    .animation(.easeInOut, value: showInput)
                }
            }
            .frame(width: 300)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 8)
        }
        .background(Color.white)
        .ignoresSafeArea()
        .onAppear {
            setupCardInfos()
            moveCardsInSections()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    showInput = true
                }
            }
        }
    }

    private func setupCardInfos() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let rows = 4
        let columns = 4
        let cellWidth = screenWidth / CGFloat(columns)
        let cellHeight = screenHeight / CGFloat(rows)

        let shuffledWords = words.shuffled().prefix(rows * columns)
        var infos: [BackgroundCardInfo] = []

        for (index, word) in shuffledWords.enumerated() {
            let row = index / columns
            let col = index % columns

            let minX = CGFloat(col) * cellWidth
            let minY = CGFloat(row) * cellHeight
            let maxX = minX + cellWidth
            let maxY = minY + cellHeight

            let x = CGFloat.random(in: minX + 20...maxX - 20)
            let y = CGFloat.random(in: minY + 20...maxY - 20)

            let pastelColor = Color(
                hue: Double.random(in: 0...1),
                saturation: Double.random(in: 0.2...0.4),
                brightness: 1.0
            )

            infos.append(BackgroundCardInfo(index: index, text: word, position: CGPoint(x: x, y: y), color: pastelColor))
        }

        self.cardInfos = infos
    }

    private func moveCardsInSections() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let rows = 4
        let columns = 4
        let cellWidth = screenWidth / CGFloat(columns)
        let cellHeight = screenHeight / CGFloat(rows)

        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 4.0)) {
                for i in 0..<cardInfos.count {
                    let row = i / columns
                    let col = i % columns

                    let minX = CGFloat(col) * cellWidth
                    let minY = CGFloat(row) * cellHeight
                    let maxX = minX + cellWidth
                    let maxY = minY + cellHeight

                    let x = CGFloat.random(in: minX + 20...maxX - 20)
                    let y = CGFloat.random(in: minY + 20...maxY - 20)

                    cardInfos[i].position = CGPoint(x: x, y: y)
                }
            }
        }
    }
}

struct BackgroundCardInfo: Hashable {
    let index: Int
    let text: String
    var position: CGPoint
    let color: Color
}

struct BackgroundCardView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.4))
                    .shadow(radius: 2)
            )
    }
}

#Preview {
    OnboardingGoalViewWrapper(isPresented: .constant(true)) { goal in
        print("입력된 목표: \(goal)")
    }
}
