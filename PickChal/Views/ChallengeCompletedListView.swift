import SwiftUI

struct ChallengeCompletedListView: View {
    let completed: [ChallengeModel]

    var body: some View {
        List {
            if completed.isEmpty {
                Text("완료한 챌린지가 없습니다.")
                    .foregroundColor(.gray)
            } else {
                ForEach(completed) { challenge in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(challenge.title)
                            .font(.headline)
                        Text(challenge.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Button {
                            shareToInstagram(for: challenge)
                        } label: {
                            Label("Instagram 스토리 공유", systemImage: "square.and.arrow.up")
                                .font(.caption)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("완료한 챌린지")
    }

    //공유 로직
    func shareToInstagram(for challenge: ChallengeModel) {
        let background = UIImage.imageWithText(
            text: "오늘의 챌린지 완료 🎉",
            size: CGSize(width: 300, height: 500),
            backgroundColor: .black,
            textColor: .white
        )

        let sticker = UIImage.challengeSticker(text: "#\(challenge.title)")

        InstagramSharer.share(
            backgroundImage: background,
            stickerImage: sticker,
            appID: "1230529985269243"
            
        )
    }
}
extension UIImage {
    static func imageWithText(text: String, size: CGSize, backgroundColor: UIColor, textColor: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
         
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]

            let textRect = CGRect(x: 0, y: size.height / 2 - 15, width: size.width, height: 30)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    static func challengeSticker(text: String, size: CGSize = CGSize(width: 250, height: 60)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            //배경 색
            UIColor.systemOrange.setFill()
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 15)
            path.fill()

            //텍스트 스타일
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]

            //텍스트 위치
            let textRect = CGRect(x: 0, y: size.height / 2 - 14, width: size.width, height: 28)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

