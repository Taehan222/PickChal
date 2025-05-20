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
                    VStack(alignment: .leading, spacing: 4) {
                        Text(challenge.title)
                            .font(.headline)
                        Text(challenge.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("총 \(challenge.totalCount)회 수행 완료")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("완료한 챌린지")
    }
}
