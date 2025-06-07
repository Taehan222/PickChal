import SwiftUI
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
    }

    private let badgeKey = "NotificationBadgeCount"
    private let userDefaults = UserDefaults.standard

    // MARK: - 권한 요청
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print(granted ? "알림 허용됨" : "알림 거부됨")
        }
    }

    // MARK: - 챌린지 알림 등록 (매일 반복)
    func scheduleChallenge(_ challenge: ChallengeModel, notificationsEnabled: Bool, increaseBadge: Bool = true) {
        guard notificationsEnabled else {
            print("🔕 알림 꺼져있어서 등록 안함")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "⏰ 챌린지 알림"
        content.body = "'\(challenge.title)' 챌린지 시간이에요!"
        content.sound = .default

        if increaseBadge {
            let badge = nextBadgeCount()
            content.badge = badge as NSNumber
            UIApplication.shared.applicationIconBadgeNumber = badge
        }

        let calendar = Calendar.current
        let alarmTime = Date().addingTimeInterval(120) // 2분 뒤
        var components = Calendar.current.dateComponents([.hour, .minute], from: alarmTime)
        //var components = Calendar.current.dateComponents([.hour, .minute], from: challenge.alarmTime)
        components.second = 0
        components.nanosecond = nil

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: challenge.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 알림 등록 실패: \(error.localizedDescription)")
            } else {
                print("✅ 알림 등록 성공 - \(challenge.title) @ \(components.hour ?? -1):\(components.minute ?? -1)")
            }
        }
    }


    // MARK: - 오늘 알림 스킵 처리
    func markTodayAlarmAsSkipped(for challenge: ChallengeModel) {
        let key = skipKey(for: challenge.id)
        UserDefaults.standard.set(true, forKey: key)
    }

    // MARK: - 스킵 키 생성
    private func skipKey(for id: UUID) -> String {
        let today = Date().todayString
        return "skipAlarm_\(id.uuidString)_\(today)"
    }

    // MARK: - 테스트 알림 (5초 후)
    func scheduleImmediateTestNotification() {
        let isOn = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        guard isOn else {
            print("🔕 알림 꺼져있어서 등록 안함")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "📣 테스트 알림"
        content.body = "알림 테스트입니다!"
        content.sound = .default

        if let imageURL = Bundle.main.url(forResource: "PickChalIcon", withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "image", url: imageURL, options: nil) {
                content.attachments = [attachment]
            }
        }

        let badge = nextBadgeCount()
        content.badge = badge as NSNumber
        UIApplication.shared.applicationIconBadgeNumber = badge

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(
            identifier: "TEST",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 테스트 알림 등록 실패: \(error.localizedDescription)")
            } else {
                print("✅ 테스트 알림 등록 완료 (5초 후 울림)")
            }
        }
    }


    // MARK: - 개별 챌린지 알림 제거
    func removeChallenge(_ id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    // MARK: - 전체 알림 제거 + 뱃지 초기화
    func removeAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        resetBadgeCount()
    }

    // MARK: - 뱃지 관리
    func resetBadgeCount() {
        userDefaults.set(0, forKey: badgeKey)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    private func nextBadgeCount() -> Int {
        let current = userDefaults.integer(forKey: badgeKey)
        let next = current + 1
        userDefaults.set(next, forKey: badgeKey)
        return next
    }

    // MARK: - Delegate 연결
    func setupDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - 알림 클릭 시 동작 (오늘 완료 여부 확인)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let id = response.notification.request.identifier
        let todayKey = "skipAlarm_\(id)_\(Date().todayString)"
        
        if UserDefaults.standard.bool(forKey: todayKey) {
            print("오늘은 챌린지 완료됨 → 알림 무시")
            completionHandler()
            return
        }

        DispatchQueue.main.async {
            TabSelectionManager.shared.switchToTab(.home)
        }
        completionHandler()
    }
}
extension Date {
    var todayString: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
