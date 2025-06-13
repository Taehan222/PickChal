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
    func handleToggleChanged(
            isOn: Bool,
            onDenied: @escaping () -> Void,
            onGranted: @escaping () -> Void
        ) {
            if isOn {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        switch settings.authorizationStatus {
                        case .authorized, .provisional:
                            onGranted()
                        case .denied:
                            onDenied()
                        case .notDetermined:
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                                DispatchQueue.main.async {
                                    granted ? onGranted() : onDenied()
                                }
                            }
                        default:
                            onDenied()
                        }
                    }
                }
            } else {
                // 알림 비활성화
                removeAll()
            }
        }
    

    // MARK: - 챌린지 알림 등록 (매일 반복)
    func scheduleChallenge(_ challenge: ChallengeModel, notificationsEnabled: Bool, increaseBadge: Bool = true) {
        guard notificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "⏰ 챌린지 알림"
        content.body = "'\(challenge.title)' 챌린지 시간이에요!"
        content.sound = .default
        if increaseBadge {
            content.badge = 1
        }

        let koreaTZ = TimeZone(identifier: "Asia/Seoul")!
        var calendar = Calendar.current
        calendar.timeZone = koreaTZ

        let now = Date()
        let nowInKorea = now.addingTimeInterval(TimeInterval(koreaTZ.secondsFromGMT(for: now)))

        var components = calendar.dateComponents([.hour, .minute], from: challenge.alarmTime)
        components.second = 0

        guard let todayTriggerDate = calendar.nextDate(after: nowInKorea, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents) else {
            return
        }

        // 중복 알림 방지 로직
        if todayTriggerDate > nowInKorea {
            let onceTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let onceRequest = UNNotificationRequest(
                identifier: "\(challenge.id.uuidString)_today",
                content: content,
                trigger: onceTrigger
            )
            UNUserNotificationCenter.current().add(onceRequest)
        } else {
            let repeatTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let repeatRequest = UNNotificationRequest(
                identifier: "\(challenge.id.uuidString)_repeat",
                content: content,
                trigger: repeatTrigger
            )
            UNUserNotificationCenter.current().add(repeatRequest)
        }

        // (선택) 디버깅 출력
        let formatter = DateFormatter()
        formatter.timeZone = koreaTZ
        formatter.dateFormat = "HH:mm"
        let formattedTime = formatter.string(from: todayTriggerDate)
        print("알림 등록 완료: \(challenge.title) - 울리는 시각: \(formattedTime)")
    }




    // MARK: - 오늘 알림 스킵 처리
    func markTodayAlarmAsSkipped(for challenge: ChallengeModel) {
        let key = skipKey(for: challenge.id)
        print("오늘 알림 스킵 등록됨 → \(key)")
        UserDefaults.standard.set(true, forKey: key)
    }

    // MARK: - 스킵 키 생성
    private func skipKey(for id: UUID) -> String {
        let today = Date().todayString
        return "skipAlarm_\(id.uuidString)_\(today)"
    }

    // MARK: - 테스트 알림 (5초 후)
    func scheduleImmediateTestNotification(increaseBadge: Bool = true) {
        let isOn = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        guard isOn else {
            print("알림 꺼져있어서 등록 안함")
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

        if increaseBadge {
            content.badge = 1
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

        let request = UNNotificationRequest(
            identifier: "TEST",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("테스트 알림 등록 실패: \(error.localizedDescription)")
            } else {
                print("테스트 알림 등록 완료 (5초 후 울림)")
            }
        }
    }


    // MARK: - 개별 챌린지 알림 제거
    func removeChallenge(_ id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        //print("개별 알림 제거: \(id.uuidString)")
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
        
        let challengeID = id
            .replacingOccurrences(of: "_today", with: "")
            .replacingOccurrences(of: "_repeat", with: "")

        let todayKey = "skipAlarm_\(challengeID)_\(Date().todayString)"

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
extension NotificationManager {
    /// 오늘 알림을 스킵 처리하고, `_today` 알림을 제거합니다.
    func skipTodayAlarm(for challenge: ChallengeModel) {
        let key = skipKey(for: challenge.id)
        UserDefaults.standard.set(true, forKey: key)
        print(" 오늘 알림 스킵 등록됨 → \(key)")

        // 오늘 울리는 일회성 알림 제거
        let todayID = "\(challenge.id.uuidString)_today"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [todayID])
        print("오늘 알림 제거됨 → ID: \(todayID)")
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
extension Challenge {
    func toModel() -> ChallengeModel {
        return ChallengeModel(
            id: self.id ?? UUID(),
            title: self.title ?? "",
            subTitle: self.subTitle ?? "",
            descriptionText: self.descriptionText ?? "",
            category: self.category ?? "",
            startDate: self.startDate ?? Date(),
            endDate: self.endDate ?? Date(),
            totalCount: Int(self.totalCount),
            createdAt: self.createdAt ?? Date(),
            alarmTime: self.alarmTime ?? Date(),
            isCompleted: self.isCompleted
        )
    }
}
