import UIKit

struct InstagramSharer {
    static func share(stickerImage: UIImage, appID: String) {
        guard let stickerData = stickerImage.pngData(),
              let urlScheme = URL(string: "instagram-stories://share?source_application=\(appID)"),
              UIApplication.shared.canOpenURL(urlScheme) else {
            print("공유 실패: 이미지 변환 또는 Instagram 미설치")
            return
        }

        let pasteboardItems: [[String: Any]] = [[
            "com.instagram.sharedSticker.stickerImage": stickerData
        ]]

        let options = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)]
        UIPasteboard.general.setItems(pasteboardItems, options: options)
        UIApplication.shared.open(urlScheme)
    }
}
