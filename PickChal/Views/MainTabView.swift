//
//  ContentView.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
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
        }
        .accentColor(Theme.Colors.primary)
        .background(Theme.Colors.background)
    }
}

#Preview {
    ContentView()
}
