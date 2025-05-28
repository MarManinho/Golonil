

import SwiftUI

struct TeamSetupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var team1Name: String = ""
    @State private var team2Name: String = ""
    @State private var team1Color: Color = .red
    @State private var team2Color: Color = .blue
    @State private var showNextScreen = false

    var body: some View {
        NavigationStack {  // <-- ADD THIS LINE
            ZStack {
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .padding()
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }

                    VStack(spacing: 8) {
                        Text("Make your")
                            .font(.title)
                            .fontWeight(.bold) +
                        Text(" Teams")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)

                        Text("Set a Name and Color to your Teams to make them more unique.")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                    }

                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.brown.opacity(0.7))
                        .overlay(
                            VStack(spacing: 30) {
                                TeamInputView(
                                    teamName: $team1Name,
                                    teamColor: $team1Color,
                                    otherTeamColor: $team2Color,
                                    title: "Team 1"
                                )

                                Divider().background(Color.gray)

                                TeamInputView(
                                    teamName: $team2Name,
                                    teamColor: $team2Color,
                                    otherTeamColor: $team1Color,
                                    title: "Team 2"
                                )
                            }
                            .padding()
                        )
                        .padding()

                    Spacer()

                    Button("Continue") {
                        showNextScreen = true
                    }
                    .buttonStyle(ImageButtonStyle(imageName: "button-basic"))
                    .padding(.bottom, 30)
                    .disabled(team1Name.isEmpty || team2Name.isEmpty)
                    .opacity((team1Name.isEmpty || team2Name.isEmpty) ? 0.5 : 1.0)

                    NavigationLink(
                        destination: TeamSetupSummaryView(
                            team1Name: team1Name,
                            team2Name: team2Name,
                            team1Color: team1Color,
                            team2Color: team2Color
                        ),
                        isActive: $showNextScreen
                    ) {
                        EmptyView()
                    }
                }
            }
            .tiledBackground()
        }
    }
}


#Preview {
    TeamSetupView()
}
