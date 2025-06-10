import SwiftUI

struct TeamSetupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var team1Name: String = ""
    @State private var team2Name: String = ""
    @State private var team1Color: Color? = nil
    @State private var team2Color: Color? = nil
    @State private var showNextScreen = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: -5) {
                    // Header with back button - FIXED: Added top padding for safe area
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .padding()
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    .padding(.top) // This ensures the button stays within the safe area

                    // Title
                    VStack(spacing: 12) {
                        HStack(spacing: 0) {
                            Text("Make your ")
                                .font(.custom("Kefa", size: 28))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Text("Teams")
                                .font(.custom("Kefa", size: 28))
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "#FF2F2F"), Color(hex: "#004AFF")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }

                        Text("Set a Name and Color to your Teams to make them more unique.")
                            .multilineTextAlignment(.center)
                            .font(.custom("Kefa", size: 16))
                            .foregroundColor(.black)
                            .padding(.horizontal, 30)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, 20)

                    // Team setup container
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.brown.opacity(0.7))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .frame(height: 440) // Fixed height to ensure proper sizing
                        .overlay(
                            VStack(spacing: 30) {
                                // Team 1
                                TeamInputSection(
                                    teamName: $team1Name,
                                    teamColor: $team1Color,
                                    otherTeamColor: $team2Color,
                                    title: "Team 1"
                                )
                                
                              
                                VStack(spacing: 15) {
                                    // Thin line above Team 2
                                    Capsule()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 300, height: 4)
                                    
                                    TeamInputSection(
                                        teamName: $team2Name,
                                        teamColor: $team2Color,
                                        otherTeamColor: $team1Color,
                                        title: "Team 2"
                                    )
                                }
                            }
                            .padding(30)
                        )
                        .padding(.horizontal, 20)

                    Spacer()

                    // Start button
                    Button(action: {
                        showNextScreen = true
                    }) {
                        Image("startButton")
                            .resizable()
                            .scaledToFit() // or .scaledToFill() depending on design
                            .frame(width: 200, height: 80) // adjust to match your button image size
                    }
                    .padding(.bottom, 30)
                    .disabled(team1Name.isEmpty || team2Name.isEmpty || team1Color == nil || team2Color == nil)
                    .opacity((team1Name.isEmpty || team2Name.isEmpty || team1Color == nil || team2Color == nil) ? 0.5 : 1.0)


                }
            }
            .tiledBackground()
            .fullScreenCover(isPresented: $showNextScreen) {
                CoinFlipView(
                    team1Name: team1Name,
                    team2Name: team2Name,
                    team1Color: team1Color ?? Color(hex: "#FF2F2F"),
                    team2Color: team2Color ?? Color(hex: "#004AFF")
                )
            }
        }
    }
}

struct TeamInputSection: View {
    @Binding var teamName: String
    @Binding var teamColor: Color?
    @Binding var otherTeamColor: Color?
    var title: String
    
    @FocusState private var isTextFieldFocused: Bool
    
    private let redColor = Color(hex: "#FF2F2F")
    private let blueColor = Color(hex: "#004AFF")

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // Team title
            Text(title)
                .font(.custom("Kefa", size: 22))
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Team name input
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.3))
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                
                ZStack(alignment: .leading) {
                    if teamName.isEmpty && !isTextFieldFocused {
                        Text("Team Name")
                            .font(.custom("Kefa", size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.leading, 20)
                    }
                    
                    TextField("", text: $teamName)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .focused($isTextFieldFocused)
                }
            }
            .frame(height: 50)

            // Color selection
            HStack(spacing: 40) {
                ColorSelectionCircle(
                    color: redColor,
                    isSelected: teamColor == redColor,
                    hasAnySelection: teamColor != nil,
                    onTap: {
                        teamColor = redColor
                        otherTeamColor = blueColor
                    }
                )
                
                ColorSelectionCircle(
                    color: blueColor,
                    isSelected: teamColor == blueColor,
                    hasAnySelection: teamColor != nil,
                    onTap: {
                        teamColor = blueColor
                        otherTeamColor = redColor
                    }
                )
            }
        }
    }
}

struct ColorSelectionCircle: View {
    var color: Color
    var isSelected: Bool
    var hasAnySelection: Bool
    var onTap: () -> Void
    
    var body: some View {
        Circle()
            .fill(
                hasAnySelection ?
                (isSelected ? color : color.opacity(0.4)) : // Dark when not selected (but only if there's a selection)
                color // Bright when no selection has been made yet
            )
            .frame(
                width: hasAnySelection ? (isSelected ? 50 : 35) : 45, // Different sizes only when there's a selection
                height: hasAnySelection ? (isSelected ? 50 : 35) : 45
            )
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
            )
            .animation(.easeInOut(duration: 0.3), value: isSelected)
            .animation(.easeInOut(duration: 0.3), value: hasAnySelection)
            .onTapGesture {
                onTap()
            }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    TeamSetupView()
}
