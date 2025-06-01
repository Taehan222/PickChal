//
//  MBTIRadioButtonView.swift
//  PickChal
//
//  Created by 윤태한 on 5/29/25.
//

import SwiftUI

struct MBTIRadioButtonView: View {
    @ObservedObject var viewModel: OnboardingVM

    let mbtiPairs: [[(abbreviation: String, meaning: String)]] = [
        [("I", "Introversion"), ("E", "Extroversion")],
        [("N", "Intuition"), ("S", "Sensing")],
        [("F", "Feeling"), ("T", "Thinking")],
        [("P", "Perceiving"), ("J", "Judging")]
    ]
    
    let pastelColors: [Color] = [
        Color(red: 227/255, green: 250/255, blue: 255/255),
        Color(red: 255/255, green: 240/255, blue: 240/255),
        Color(red: 245/255, green: 255/255, blue: 245/255),
        Color(red: 255/255, green: 255/255, blue: 214/255),
        Color(red: 252/255, green: 240/255, blue: 255/255),
        Color(red: 255/255, green: 252/255, blue: 227/255),
        Color(red: 227/255, green: 255/255, blue: 255/255),
        Color(red: 255/255, green: 237/255, blue: 252/255)
    ]
    
    @State private var selections: [String?] = Array(repeating: nil, count: 4)
    @State private var navigateNext = false
    
    // 애니메이션용 showRow 배열
    @State private var showRow: [Bool] = [false, false, false, false]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack(spacing: 16) {
                    Text("당신의 MBTI 성향을 선택하세요")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 16)
                    
                    VStack(spacing: 12) {
                        ForEach(0..<mbtiPairs.count, id: \.self) { row in
                            if showRow[row] {
                                RowView(
                                    row: row,
                                    selections: $selections,
                                    mbtiPairs: mbtiPairs,
                                    pastelColors: pastelColors,
                                    geo: geo
                                )
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: showRow[row])
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    if selections.allSatisfy({ $0 != nil }) {
                        NavigationLink(
                            destination: OnboardingGoalView()
                                .environmentObject(viewModel),
                            isActive: $navigateNext
                        ) {
                            Button {
                                let mbti = selections.compactMap { $0 }.joined()
                                print("선택한 MBTI: \(mbti)")
                                if let finalMBTI = MBTIType(rawValue: mbti) {
                                    viewModel.mbti = finalMBTI
                                } else {
                                    viewModel.mbti = .INTJ
                                }
                                navigateNext = true
                            } label: {
                                HStack {
                                    Text("다음")
                                        .font(.headline)
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: geo.size.width - 40, minHeight: 50)
                                .background(Color(red: 250/255, green: 250/255, blue: 250/255))
                                .cornerRadius(20)
                                .padding(.horizontal, 20)
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                        .padding(.bottom, 20)
                        .animation(.easeInOut, value: selections)
                    }
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .onAppear {
                    showRowsSequentially()
                }
            }
        }
    }

    func showRowsSequentially() {
        for i in 0..<showRow.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 + Double(i) * 0.4) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showRow[i] = true
                }
            }
        }
    }
}

private struct RowView: View {
    let row: Int
    @Binding var selections: [String?]
    let mbtiPairs: [[(abbreviation: String, meaning: String)]]
    let pastelColors: [Color]
    let geo: GeometryProxy
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<2, id: \.self) { col in
                let trait = mbtiPairs[row][col].abbreviation
                let meaning = mbtiPairs[row][col].meaning
                let index = row * 2 + col
                
                Button(action: {
                    withAnimation {
                        selections[row] = trait
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(trait)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(meaning)
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                    .frame(
                        width: ((geo.size.width - 40 - 16) / 2) * 0.8,
                        height: ((geo.size.height - 40 - 48) / 4) * 0.8
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(pastelColors[index])
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(selections[row] == trait ? Color.blue : Color.clear, lineWidth: 4)
                            )
                    )
                    .foregroundColor(.black)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 4)
                }
            }
        }
    }
}

#Preview {
    MBTIRadioButtonView(viewModel: OnboardingVM())
}
