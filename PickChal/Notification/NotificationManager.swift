import SwiftUI
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
    }

    private let badgeKey = "NotificationBadgeCount"
    private let userDefaults = UserDefaults.standard

    //  권한 요청
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print(granted ? " 알림 허용됨" : " 알림 거부됨")
        }
    }

    // 챌린지 알림 예약 (매일 반복)
    func scheduleChallenge(_ challenge: ChallengeModel) {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else {
            print("알림 꺼져있어서 등록 안함")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "⏰ 챌린지 알림"
        content.body = "'\(challenge.title)' 챌린지 시간이에요!"
        content.sound = .default

        let badge = nextBadgeCount()
        content.badge = badge as NSNumber
        UIApplication.shared.applicationIconBadgeNumber = badge

        let components = Calendar.current.dateComponents([.hour, .minute], from: challenge.alarmTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: challenge.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
        print("알림 등록 완료: \(challenge.title)")
    }

    //  테스트용 알림 (5초 후)
    func scheduleImmediateTestNotification(for challenge: ChallengeModel) {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else {
            print("알림 꺼져있어서 등록 안함")
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "📣 테스트 알림"
        content.body = "'\(challenge.title)' 알림 테스트입니다!"
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
            identifier: "TEST_\(challenge.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(" 테스트 알림 실패: \(error.localizedDescription)")
            } else {
                print(" 테스트 알림 예약 완료")
            }
        }
    }

    // 개별 알림 삭제
    func removeChallenge(_ id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    //  전체 알림 제거 + 뱃지 초기화
    func removeAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        resetBadgeCount()
    }

    // 뱃지 관련
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

    func setupDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        DispatchQueue.main.async {
            //탭 전환: 홈으로 이동
            TabSelectionManager.shared.switchToTab(.home)
        }
        completionHandler()
    }
}
