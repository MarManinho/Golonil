
import SwiftUI

struct TeamInputView: View {
    @Binding var teamName: String
    @Binding var teamColor: Color
    @Binding var otherTeamColor: Color
    var title: String

    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            TextField("Team Name", text: $teamName)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)

            HStack(spacing: 30) {
                ColorCircle(color: .red, isSelected: teamColor == .red) {
                    teamColor = .red
                    otherTeamColor = .blue
                }

                ColorCircle(color: .blue, isSelected: teamColor == .blue) {
                    teamColor = .blue
                    otherTeamColor = .red
                }
            }
        }
    }
}

struct ColorCircle: View {
    var color: Color
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 40, height: 40)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: isSelected ? 4 : 0)
            )
            .onTapGesture {
                onTap()
            }
    }
}
