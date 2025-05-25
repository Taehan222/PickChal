//
//  MovingWordView.swift
//  PickChal
//
//  Created by 조수원 on 5/26/25.
//

import SwiftUI

struct MovingWordsBackgroundView: View {
    let words: [String]
    let lineCount: Int

    private let screenWidth = UIScreen.main.bounds.width
    private let totalDistance: CGFloat = UIScreen.main.bounds.width + 400
    private let speed: CGFloat = 185

    @State private var lineInfos: [LineInfo] = []

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let movingDistance = CGFloat(time) * speed

            ZStack {
                ForEach(0..<lineInfos.count, id: \.self) { index in
                    let text = words[index % words.count]
                    let info = lineInfos[index]

                    let offsetX = screenWidth
                        - (movingDistance + info.xStartOffset).truncatingRemainder(dividingBy: totalDistance)

                    Text(text)
                        .font(.system(size: info.fontSize, weight: .medium))
                        .foregroundColor(info.color.opacity(info.opacity))
                        .offset(x: offsetX, y: info.yOffset)
                }
            }
        }
        .onAppear {
            if lineInfos.isEmpty {
                let baseYSpacing: CGFloat = 60
                let randomJitter: CGFloat = 30

                let halfTotalHeight = (CGFloat(lineCount - 1) * baseYSpacing) / 2

                lineInfos = (0..<lineCount).map { index in
                    LineInfo(
                        yOffset: (CGFloat(index) * baseYSpacing - halfTotalHeight)
                            + CGFloat.random(in: -randomJitter...randomJitter),
                        xStartOffset: CGFloat.random(in: -200...200),
                        fontSize: CGFloat.random(in: 15...24),
                        opacity: Double.random(in: 0.3...0.7),
                        color: Color(
                            hue: Double.random(in: 0...1),
                            saturation: Double.random(in: 0.3...0.8),
                            brightness: Double.random(in: 0.8...1.0)
                        )
                    )
                }
            }
        }
    }

    struct LineInfo {
        let yOffset: CGFloat
        let xStartOffset: CGFloat
        let fontSize: CGFloat
        let opacity: Double
        let color: Color
    }
}
