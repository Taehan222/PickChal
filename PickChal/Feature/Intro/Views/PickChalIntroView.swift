//
//  PickChalIntroView.swift
//  PickChal
//
//  Created by 조수원 on 6/5/25.
//

import SwiftUI

struct PickChalIntroView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isVisible: Bool = false
    @State private var showImage: Bool = false
    @State private var navigateNext = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if showImage {
                        Image(colorScheme == .dark ? "logoDark" : "logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                    }

                    if isVisible {
                        Text("PickChal")
                            .customAttribute(EmphasisAttribute())
                            .foregroundStyle(Color.primary)
                            .bold()
                            .font(.system(size: 42, weight: .semibold, design: .rounded))
                            .transition(TextTransition())
                            .padding(.top, -2)
                    }
                }
            }
            .onAppear {
                showImage = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isVisible = true
                    }
                }
            }
        }
    }
}

struct EmphasisAttribute: TextAttribute {}

struct AppearanceEffectRenderer: TextRenderer, Animatable {
    var elapsedTime: TimeInterval
    var elementDuration: TimeInterval
    var totalDuration: TimeInterval

    var spring: Spring {
        .snappy(duration: elementDuration - 0.05, extraBounce: 0.4)
    }

    var animatableData: Double {
        get { elapsedTime }
        set { elapsedTime = newValue }
    }

    init(elapsedTime: TimeInterval, elementDuration: Double = 0.6, totalDuration: TimeInterval) {
        self.elapsedTime = min(elapsedTime, totalDuration)
        self.elementDuration = min(elementDuration, totalDuration)
        self.totalDuration = totalDuration
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for run in layout.flattenedRuns {
            if run[EmphasisAttribute.self] != nil {
                let delay = elementDelay(count: run.count)
                for (index, slice) in run.enumerated() {
                    let timeOffset = TimeInterval(index) * delay
                    let elementTime = max(0, min(elapsedTime - timeOffset, elementDuration))
                    var copy = context
                    draw(slice, at: elementTime, in: &copy)
                }
            } else {
                var copy = context
                copy.opacity = UnitCurve.easeIn.value(at: elapsedTime / 0.2)
                copy.draw(run)
            }
        }
    }

    func draw(_ slice: Text.Layout.RunSlice, at time: TimeInterval, in context: inout GraphicsContext) {
        let progress = time / elementDuration
        let opacity = UnitCurve.easeIn.value(at: 1.4 * progress)
        let blurRadius = slice.typographicBounds.rect.height / 16 * UnitCurve.easeIn.value(at: 1 - progress)
        let translationY = spring.value(fromValue: -slice.typographicBounds.descent, toValue: 0, initialVelocity: 0, time: time)

        context.translateBy(x: 0, y: translationY)
        context.addFilter(.blur(radius: blurRadius))
        context.opacity = opacity
        context.draw(slice, options: .disablesSubpixelQuantization)
    }

    func elementDelay(count: Int) -> TimeInterval {
        let count = TimeInterval(count)
        let remainingTime = totalDuration - count * elementDuration
        return max(remainingTime / (count + 1), (totalDuration - elementDuration) / count)
    }
}

extension Text.Layout {
    var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
        self.flatMap { line in line }
    }

    var flattenedRunSlices: some RandomAccessCollection<Text.Layout.RunSlice> {
        flattenedRuns.flatMap { $0 }
    }
}

struct TextTransition: Transition {
    static var properties: TransitionProperties {
        TransitionProperties(hasMotion: true)
    }

    func body(content: Content, phase: TransitionPhase) -> some View {
        let duration = 2.0
        let elapsedTime = phase.isIdentity ? duration : 0
        let renderer = AppearanceEffectRenderer(
            elapsedTime: elapsedTime,
            elementDuration: 0.4,
            totalDuration: duration
        )

        content.transaction { transaction in
            if !transaction.disablesAnimations {
                transaction.animation = .linear(duration: duration)
            }
        } body: { view in
            view.textRenderer(renderer)
        }
    }
}

#Preview {
    PickChalIntroView()
}
