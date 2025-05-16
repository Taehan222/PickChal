//
//  PickChalApp.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI

@main
struct PickChalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
