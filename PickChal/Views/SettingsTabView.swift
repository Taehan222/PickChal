//
//  SettingsTabView.swift
//  SampleApp03
//
//  Created by 윤태한 on 5/16/25.
//

import SwiftUI

struct SettingsTabView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkMode") private var darkMode = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("일반").foregroundColor(Theme.Colors.text)) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("알림 설정", systemImage: "bell.fill")
                    }
                    Toggle(isOn: $darkMode) {
                        Label("다크 모드", systemImage: "moon.stars.fill")
                    }
                }
                Section(header: Text("계정").foregroundColor(Theme.Colors.text)) {
                    NavigationLink(destination: Text("프로필 설정")) {
                        Label("프로필 편집", systemImage: "person.circle")
                    }
                    NavigationLink(destination: Text("비밀번호 변경")) {
                        Label("비밀번호 변경", systemImage: "lock.fill")
                    }
                }
            }
            .accentColor(Theme.Colors.primary)
            .navigationTitle("설정")
        }
    }
}
