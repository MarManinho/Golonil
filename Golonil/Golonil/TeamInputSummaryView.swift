
import SwiftUI

struct TeamSetupSummaryView: View {
    var team1Name: String
    var team2Name: String
    var team1Color: Color
    var team2Color: Color

    @State private var showCoinFlip = false

    var body: some View {
        NavigationStack {
            ZStack {

                VStack {
                    VStack(spacing: 8) {
                        Text("Teams are Ready!")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Here are your ")
                            .font(.title2)
                            .fontWeight(.medium) +
                        Text("Teams")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                    }

                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.brown.opacity(0.7))
                        .overlay(
                            VStack(spacing: 30) {
                                TeamInputView(teamName: .constant(team1Name), teamColor: .constant(team1Color), otherTeamColor: .constant(team2Color), title: "Team 1")
                                Divider().background(Color.gray)
                                TeamInputView(teamName: .constant(team2Name), teamColor: .constant(team2Color), otherTeamColor: .constant(team1Color), title: "Team 2")
                            }
                            .padding()
                        )
                        .padding()

                    Spacer()

                    Button("Continue") {
                        showCoinFlip = true
                    }
                    .buttonStyle(ImageButtonStyle(imageName: "button-basic"))
                    .padding(.bottom, 30)

                    NavigationLink("", destination:
                        CoinFlipView(
                            team1Name: team1Name,
                            team2Name: team2Name,
                            team1Color: team1Color,
                            team2Color: team2Color
                        ),
                        isActive: $showCoinFlip
                    ).hidden()
                }
                .padding()
            }
            .tiledBackground()
        }
    }
}
    
