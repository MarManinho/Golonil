import SwiftUI

struct TeamSummaryRow: View {
    var teamName: String
    var teamColor: Color

    var body: some View {
        HStack(spacing: 20) {
            Circle()
                .fill(teamColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )

            Text(teamName)
                .font(.title2)
                .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
}
