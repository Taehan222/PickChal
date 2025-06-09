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
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @State private var showIntro = true

    init() {
        // 앱 시작 시: 알림 뱃지 초기화 및 델리게이트 설정
        NotificationManager.shared.resetBadgeCount()
        NotificationManager.shared.setupDelegate()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showIntro {
                    PickChalIntroView()
                } else if !onboardingCompleted {
                    NavigationStack {
                        OnboardingIntroView(viewModel: OnboardingVM())
                    }
                } else {
                    ContentView()
                        .environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext)
                        .environmentObject(tabManager)
                        .environmentObject(themeManager)
                }
            }
            .onAppear {
                if onboardingCompleted {
                    tabManager.switchToTab(.home)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        showIntro = false
                    }
                }
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    NotificationManager.shared.resetBadgeCount()
                    NotificationManager.shared.setupDelegate()
                   
                }
            }
        }
    }
}
