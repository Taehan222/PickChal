import SwiftUI

final class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") private var selectedThemeRawValue: String = AppTheme.default.rawValue

    @Published var currentTheme: AppTheme

    init() {
        // ⚠️ 여기에서 직접 self.selectedThemeRawValue 사용하면 안됨
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme")
        let initialTheme = AppTheme(rawValue: savedTheme ?? "") ?? .default
        self.currentTheme = initialTheme
    }

    func updateTheme(_ newTheme: AppTheme) {
        currentTheme = newTheme
        selectedThemeRawValue = newTheme.rawValue
    }
}
