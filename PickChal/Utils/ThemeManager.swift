import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppThemeColor = .lavender
}
