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
    @StateObject var tabManager = TabSelectionManager.shared
    
    init(){
        NotificationManager.shared.requestPermission()
        NotificationManager.shared.resetBadgeCount()
        NotificationManager.shared.setupDelegate()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataManager.shared.container.viewContext)
                .environmentObject(tabManager)
                .onChange(of: scenePhase) { phase in
                                    if phase == .active {
                                        NotificationManager.shared.resetBadgeCount()
                                    }
                                }
        }
    }
}
