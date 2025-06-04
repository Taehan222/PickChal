//
//  PickChalApp.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI

@main
struct PickChalApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var themeManager = ThemeManager()
    @StateObject var tabManager = TabSelectionManager.shared
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false // 인트로 뷰 완료 여부 저장

    init() {
        // 앱 시작 시: 알림 뱃지 초기화 및 델리게이트 설정
        NotificationManager.shared.resetBadgeCount()
        NotificationManager.shared.setupDelegate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext)
                .environmentObject(tabManager)
                .environmentObject(themeManager)
                .overlay {
                    if !onboardingCompleted {
                        NavigationStack {
                            OnboardingIntroView(viewModel: OnboardingVM())
                        }
                        .transition(.move(edge: .trailing))
                    }
                }
                // 인트로 뷰 완료되면 홈으로 자동 이동
                .onAppear {
                    if onboardingCompleted {
                        tabManager.switchToTab(.home)
                    }
                }
                // 앱 실행 시 알림 뱃지 초기화
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        NotificationManager.shared.resetBadgeCount()
                    }
                }
        }
    }
}
