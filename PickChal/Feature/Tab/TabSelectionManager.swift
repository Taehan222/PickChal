import Foundation

final class TabSelectionManager: ObservableObject {
    static let shared = TabSelectionManager()

    @Published var selectedTab: Int = AppTab.home.rawValue

    func switchToTab(_ tab: AppTab) {
        selectedTab = tab.rawValue
    }
}

enum AppTab: Int {
    case recommend = 0
    case home = 1
    case my = 2
}
