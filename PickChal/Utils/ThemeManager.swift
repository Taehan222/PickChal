import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .lavender
}
