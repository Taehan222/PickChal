//
//  ContentView.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var tabManager: TabSelectionManager
    @StateObject var statsVM = StatisticsViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    var body: some View {
        TabView(selection: $tabManager.selectedTab) {
            RecommendationTabView()
                .tabItem {
                    Image(systemName: "lightbulb")
                    Text("Recommend")
                }
                .tag(0)
            
            HomeTabView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(1)
            
            SettingsTabView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("MY")
                }
                .tag(2)
                .environmentObject(statsVM)
        }
        .onAppear {
            statsVM.loadStatistics()
            statsVM.registerNotificationsIfNeeded()
        }
        
        .accentColor(Theme.Colors.primary)
        .background(Theme.Colors.background)
        
        //ThemeManager 사용예시
        //.accentColor(themeManager.currentTheme.accentColor)
        //.background(themeManager.currentTheme.backgroundColor)
        
        
    }
}

#Preview {
    ContentView()
        .environmentObject(TabSelectionManager.shared)
        .environmentObject(StatisticsViewModel())
}

