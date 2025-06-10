import SwiftUI

// Updated GameExplanationView to accept and pass card data
struct GameExplanationView: View {
    var team1Name: String
    var team2Name: String
    var team1Color: Color
    var team2Color: Color
    var ballTeam: String // Which team has the ball
    var guessingTeam: String // Which team is guessing
    
    // Add card bindings
    @Binding var team1Cards: [String]
    @Binding var team2Cards: [String]
    
    @Environment(\.dismiss) var dismiss
    @State private var showingGamePlay = false

    var body: some View {
        ZStack {
            // Background
            Image("BackgroundPattern")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with pause button
                HStack {
                    Spacer()
                    Button(action: {
                        // Handle pause action
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // Main content
                VStack(spacing: 40) {
                    // Team with ball section
                    VStack(spacing: 15) {
                        Text("Team \(ballTeam)")
                            .font(.custom("Kefa", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(ballTeam == team1Name ? team1Color : team2Color)
                        
                        Text("Your team has the\nball for this round.")
                            .font(.custom("Kefa", size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                    }
                    
                    // Team guessing section
                    VStack(spacing: 15) {
                        Text("Team \(guessingTeam)")
                            .font(.custom("Kefa", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(guessingTeam == team1Name ? team1Color : team2Color)
                        
                        Text("Your team is guessing\nfor this round.")
                            .font(.custom("Kefa", size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                    }
                    
                    // Important instruction
                    VStack(spacing: 10) {
                        Text("Keep the phone\nto yourselves!")
                            .font(.custom("Kefa", size: 36))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // Next button
                Button(action: {
                    showingGamePlay = true
                }) {
                    Image("nextButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 80)
                }
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showingGamePlay) {
            ModifiedGamePlayView(
                team1Name: team1Name,
                team2Name: team2Name,
                team1Color: team1Color,
                team2Color: team2Color,
                ballTeam: ballTeam,
                guessingTeam: guessingTeam,
                team1Cards: $team1Cards,
                team2Cards: $team2Cards
            )
        }
    }
}

// Updated ModifiedGamePlayView with card management
struct ModifiedGamePlayView: View {
    var team1Name: String
    var team2Name: String
    var team1Color: Color
    var team2Color: Color
    @State private var ballTeam: String
    @State private var guessingTeam: String
    
    // Add card bindings
    @Binding var team1Cards: [String]
    @Binding var team2Cards: [String]
    
    @State private var team1Score = 0
    @State private var team2Score = 0
    @State private var timeRemaining = 180
    @State private var timer: Timer?
    @State private var showingScorePopup = false
    @State private var showingGameOver = false
    @State private var winningTeam = ""
    @State private var isGameStarted = false
    @State private var bellPressed = false
    @State private var showingCards = false
    
    @Environment(\.dismiss) var dismiss
    
    init(team1Name: String, team2Name: String, team1Color: Color, team2Color: Color,
         ballTeam: String, guessingTeam: String, team1Cards: Binding<[String]>, team2Cards: Binding<[String]>) {
        self.team1Name = team1Name
        self.team2Name = team2Name
        self.team1Color = team1Color
        self.team2Color = team2Color
        self._ballTeam = State(initialValue: ballTeam)
        self._guessingTeam = State(initialValue: guessingTeam)
        self._team1Cards = team1Cards
        self._team2Cards = team2Cards
    }
    
    // Get current guessing team's cards
    private var currentGuessingTeamCards: Binding<[String]> {
        return guessingTeam == team1Name ? $team1Cards : $team2Cards
    }
    
    // Format time as MM:SS
    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            // Background
            Image("BackgroundPattern")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with scores and timer
                VStack(spacing: 10) {
                    // Pause button
                    HStack {
                        Spacer()
                        Button(action: {
                            pauseGame()
                        }) {
                            Image(systemName: "pause.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Scores and Timer
HStack {
                        // Team 1 Score
                        VStack {
                            Text(team1Name)
                                .font(.custom("Kefa", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(team1Color)
                            Text("\(team1Score)")
                                .font(.custom("Kefa", size: 32))
                                .fontWeight(.bold)
                                .foregroundColor(team1Color)
                        }
                        
                        Spacer()
                        
                        // Timer in center
                        VStack(spacing: 5) {
                            Text(formattedTime)
                                .font(.custom("Kefa", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(15)
                            
                            // Current teams indicator
                            Text("Team \(guessingTeam) is guessing")
                                .font(.custom("Kefa", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(guessingTeam == team1Name ? team1Color : team2Color)
                        }
                        
                        Spacer()
                        
                        // Team 2 Score
                        VStack {
                            Text(team2Name)
                                .font(.custom("Kefa", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(team2Color)
                            Text("\(team2Score)")
                                .font(.custom("Kefa", size: 32))
                                .fontWeight(.bold)
                                .foregroundColor(team2Color)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
                
                Spacer()
                
                // Main content area
                if !isGameStarted {
                    VStack(spacing: 30) {
                        // Instructions
                        Text("Tap the Bell to\nStart the round")
                            .font(.custom("Kefa", size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                        
                        // Arrow pointing down
                        Image(systemName: "arrow.down")
                            .font(.title)
                            .foregroundColor(.black)
                        
                        // Bell
                        Button(action: {
                            handleBellTap()
                        }) {
                            Image(systemName: "bell.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .scaleEffect(bellPressed ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: bellPressed)
                    }
                } else {
                    // Game in progress
                    VStack(spacing: 40) {
                        VStack(spacing: 30) {
                            VStack(spacing: 15) {
Text("Team \(ballTeam)")
                                    .font(.custom("Kefa", size: 32))
                                    .fontWeight(.bold)
                                    .foregroundColor(ballTeam == team1Name ? team1Color : team2Color)
                                
                                Text("Has the ball")
                                    .font(.custom("Kefa", size: 24))
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }
                            
                            VStack(spacing: 15) {
                                Text("Team \(guessingTeam)")
                                    .font(.custom("Kefa", size: 32))
                                    .fontWeight(.bold)
                                    .foregroundColor(guessingTeam == team1Name ? team1Color : team2Color)
                                
                                Text("Is guessing")
                                    .font(.custom("Kefa", size: 24))
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                            }
                        }
                        
                        // Show Cards button for guessing team
                        Button(action: {
                            showingCards = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.stack.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                
                                Text("View  Cards (\(currentGuessingTeamCards.wrappedValue.count))")
                                    .font(.custom("Kefa", size: 20))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                
                                Image(systemName: "rectangle.stack.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(guessingTeam == team1Name ? team1Color : team2Color)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                            )
                        }
                        .disabled(currentGuessingTeamCards.wrappedValue.isEmpty)
                        .opacity(currentGuessingTeamCards.wrappedValue.isEmpty ? 0.5 : 1.0)
                    }
                }
                
                Spacer()
                
                // Bottom button
                if isGameStarted {
                    Button(action: {
                        finishRound()
                    }) {
                        Image("finishRound")  
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 90)  // adjust size as needed
                    }
                    .padding(.bottom, 50)
                }

            }
        }
        .onDisappear {
            stopTimer()
        }
        .overlay(
            // Score popup
            Group {
                if showingScorePopup {
                    ScorePopupView(
                        guessingTeam: guessingTeam,
                        ballTeam: ballTeam,
                        guessingTeamColor: guessingTeam == team1Name ? team1Color : team2Color,
                        ballTeamColor: ballTeam == team1Name ? team1Color : team2Color,
                        onScoreSelected: { result in
                            handleScoreSelection(result: result)
                        }
                    )
                }
            }
        )
        .fullScreenCover(isPresented: $showingGameOver) {
            GameOverView(
                winningTeam: winningTeam,
                winningTeamColor: winningTeam == team1Name ? team1Color : team2Color,
                team1Name: team1Name,
                team2Name: team2Name,
                team1Score: team1Score,
                team2Score: team2Score
            )
        }
        .sheet(isPresented: $showingCards) {
            TeamCardsView(
                teamName: guessingTeam,
                teamColor: guessingTeam == team1Name ? team1Color : team2Color,
                cards: currentGuessingTeamCards
            )
        }
    }
    
    private func handleBellTap() {
        bellPressed = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            bellPressed = false
        }
        
        if !isGameStarted {
            startGame()
        }
    }
    
    private func startGame() {
        isGameStarted = true
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                finishRound()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func pauseGame() {
        if isGameStarted {
            stopTimer()
            // Show pause menu or handle pause logic
        } else {
            dismiss()
        }
    }
    
    private func finishRound() {
        stopTimer()
        showingScorePopup = true
    }
    
    private func handleScoreSelection(result: ScoreResult) {
        showingScorePopup = false
        
        switch result {
        case .guessedIn1Move:
            // Guessing team gets 2 points, teams switch
            if guessingTeam == team1Name {
                team1Score += 2
            } else {
                team2Score += 2
            }
            // Switch teams
            let tempBall = ballTeam
            ballTeam = guessingTeam
            guessingTeam = tempBall
            
        case .guessedButNot1Move:
            // Guessing team gets 0 points, teams switch
            // No points awarded
            // Switch teams
            let tempBall = ballTeam
            ballTeam = guessingTeam
            guessingTeam = tempBall
            
        case .didNotGuess:
            // Ball team gets 1 point, ball team keeps the ball
            if ballTeam == team1Name {
                team1Score += 1
            } else {
                team2Score += 1
            }
// Teams don't switch - ball team keeps the ball
        }
        
        // Check for winner
        if team1Score >= 9 {
            winningTeam = team1Name
            showingGameOver = true
            return
        } else if team2Score >= 9 {
            winningTeam = team2Name
            showingGameOver = true
            return
        }
        
        // Reset for next round
        timeRemaining = 180
        isGameStarted = false // Reset to bell screen for next round
    }
}

// Enhanced TeamCardsView with better card display
struct TeamCardsView: View {
    let teamName: String
    let teamColor: Color
    @Binding var cards: [String]
    @Environment(\.dismiss) var dismiss
    @State private var selectedCard: String? = nil
    @State private var showingCardDetail = false
    @State private var showingConfirmation = false
    
    // Card descriptions mapping
    private let cardDescriptions: [String: String] = [
        "card1": "A One vs One Duel will be done between one member of each team. The winner will get the ball for the next round.",
        "card2": "The Guessing team can use 3 more Empty Replays on the other team with this card.",
        "card3": "The Guessing team can guess the hand with Goal. If they fail, the game continues.",
        "card4": "Guessing team can ask one question from the other team. The player who is questioned should tell the truth.",
        "card5": "By correctly emptying one hand, the Master of the opposing team is required to empty another hand of the team."
    ]
    
    private let cardTitles: [String: String] = [
        "card1": "Duel Card",
        "card2": "Empty Replay Card",
        "card3": "Goal Guess Card",
        "card4": "Truth Question Card",
        "card5": "Master Control Card"
    ]
    
    var body: some View {
        ZStack {
            // Background
            Image("BackgroundPattern")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                            Text("Back")
                                .font(.custom("Kefa", size: 16))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.8))
                        )
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("Team \(teamName)")
                            .font(.custom("Kefa", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(teamColor)
                        Text("Special Cards")
                            .font(.custom("Kefa", size: 16))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    // Card count badge
                    HStack(spacing: 4) {
                        Image(systemName: "rectangle.stack.fill")
                            .font(.caption)
                        Text("\(cards.count)")
                            .font(.custom("Kefa", size: 14))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(teamColor)
                    )
                }
                .padding(.horizontal)
                .padding(.top)
                
                if cards.isEmpty {
                    // No cards remaining - enhanced empty state
                    VStack(spacing: 30) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "rectangle.stack.badge.minus")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 10) {
                            Text("No Cards Left")
                                .font(.custom("Kefa", size: 28))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            Text("You've used all your special cards.\nReady to play strategically!")
                                .font(.custom("Kefa", size: 16))
                                .foregroundColor(.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Text("Continue Game")
                                .font(.custom("Kefa", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(teamColor)
                                )
                        }
                        .padding(.bottom, 30)
                    }
                } else {
                    // Display cards with enhanced grid
                    VStack(spacing: 16) {
                        Text("Tap any card to view details and use it")
                            .font(.custom("Kefa", size: 16))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 24) {
                                ForEach(cards, id: \.self) { cardName in
                                    CardTileView(
                                        cardName: cardName,
                                        cardTitle: cardTitles[cardName] ?? "Special Card",
                                        teamColor: teamColor
                                    ) {
                                        selectedCard = cardName
                                        showingCardDetail = true
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Enhanced card detail modal
            if showingCardDetail, let card = selectedCard {
                CardDetailModalView(
                    cardName: card,
                    cardTitle: cardTitles[card] ?? "Special Card",
                    cardDescription: cardDescriptions[card] ?? "No description available",
                    teamColor: teamColor,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingCardDetail = false
                            selectedCard = nil
                        }
                    },
                    onUseCard: {
                        useCard(card)
                        showingCardDetail = false
                        selectedCard = nil
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(1000)
            }
                
        }
        .navigationBarHidden(true)
    }
    
    private func useCard(_ cardName: String) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            cards.removeAll { $0 == cardName }
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Auto-dismiss if no cards left
        if cards.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
    }
}

// Individual card tile component
struct CardTileView: View {
    let cardName: String
    let cardTitle: String
    let teamColor: Color
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Card image with enhanced styling
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    Image(cardName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 150)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(teamColor.opacity(0.3), lineWidth: 2)
                        )
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                
                // Card title
                VStack(spacing: 4) {
                    Text(cardTitle)
                        .font(.custom("Kefa", size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption2)
                        Text("Tap to Use")
                            .font(.custom("Kefa", size: 12))
                    }
                    .foregroundColor(teamColor)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(teamColor.opacity(0.4), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// Enhanced card detail modal
struct CardDetailModalView: View {
    let cardName: String
    let cardTitle: String
    let cardDescription: String
    let teamColor: Color
    let onDismiss: () -> Void
    let onUseCard: () -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(cardTitle)
                        .font(.custom("Kefa", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Invisible spacer for balance
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .opacity(0)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .mask(
                            Rectangle()
                                .padding(.bottom, -20)
                        )
                )
                
                // Content
                VStack(spacing: 24) {
                    // Large card display
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                        
                        Image(cardName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 160, height: 240)
                            .cornerRadius(16)
                    }
                    .frame(width: 180, height: 260)
                    
                    // Description with better formatting
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(teamColor)
                            Text("Card Effect")
                                .font(.custom("Kefa", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        
                        Text(cardDescription)
                            .font(.custom("Kefa", size: 15))
                            .foregroundColor(.black.opacity(0.8))
                            .lineSpacing(6)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 8)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(teamColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(teamColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Action button
                    Button(action: onUseCard) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                            Text("Use This Card")
                                .font(.custom("Kefa", size: 18))
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(teamColor)
                                .shadow(color: teamColor.opacity(0.4), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .mask(
                            Rectangle()
                                .padding(.top, -20)
                        )
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 30)
        }
    }
}

// Other existing structs remain the same...
enum ScoreResult {
    case guessedIn1Move      // 2 points to guessing team, switch teams
    case guessedButNot1Move  // 0 points to guessing team, switch teams
    case didNotGuess         // 1 point to ball team, ball team keeps ball
}
struct ScorePopupView: View {
    let guessingTeam: String
    let ballTeam: String
    let guessingTeamColor: Color
    let ballTeamColor: Color
    let onScoreSelected: (ScoreResult) -> Void
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("How did Team \(guessingTeam) do?")
                    .font(.custom("Kefa", size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 20) {
                    // Option 1: Got ball in 1 move (2 points to guessing team)
                    Button(action: {
                        onScoreSelected(.guessedIn1Move)
                    }) {
                        VStack(spacing: 10) {
                            Text("Got the ball in 1 move")
                                .font(.custom("Kefa", size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.green)
                        )
                    }
                    
                    // Option 2: Got ball but not in 1 move (0 points to guessing team)
                    Button(action: {
                        onScoreSelected(.guessedButNot1Move)
                    }) {
                        VStack(spacing: 10) {
                            Text("Got the ball (not in 1 move)")
                                .font(.custom("Kefa", size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                        )
                    }
                    
                    // Option 3: Did not get ball (1 point to ball team)
                    Button(action: {
                        onScoreSelected(.didNotGuess)
                    }) {
                        VStack(spacing: 10) {
                            Text("Did not get the ball")
                                .font(.custom("Kefa", size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.red)
                        )
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(guessingTeamColor, lineWidth: 3)
                    )
            )
            .padding(.horizontal, 40)
        }
    }
}
struct GameOverView: View {
    let winningTeam: String
    let winningTeamColor: Color
    let team1Name: String
    let team2Name: String
    let team1Score: Int
    let team2Score: Int
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Image("BackgroundPattern")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Winner announcement
                VStack(spacing: 20) {
                    Text("🎉 GAME OVER 🎉")
                        .font(.custom("Kefa", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("Team \(winningTeam) Wins!")
                        .font(.custom("Kefa", size: 36))
                        .fontWeight(.bold)
                        .foregroundColor(winningTeamColor)
                        .multilineTextAlignment(.center)
                }
                
                // Final scores
                HStack(spacing: 40) {
                    VStack(spacing: 10) {
                        Text(team1Name)
                            .font(.custom("Kefa", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(team1Name == winningTeam ? winningTeamColor : .gray)
                        Text("\(team1Score)")
                            .font(.custom("Kefa", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    
                    Text("VS")
                        .font(.custom("Kefa", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    VStack(spacing: 10) {
                        Text(team2Name)
                            .font(.custom("Kefa", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(team2Name == winningTeam ? winningTeamColor : .gray)
                        Text("\(team2Score)")
                            .font(.custom("Kefa", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2)
                        )
                )
                
                Spacer()
                
                // Play again button
                Button(action: {
                    dismiss()
                }) {
                    Text("Play Again")
                        .font(.custom("Kefa", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 40)
                                .fill(winningTeamColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        )
                }
                .padding(.bottom, 50)
            }
        }
    }
}

// Extension to darken colors
extension Color {
    func darker(by percentage: Double = 0.2) -> Color {
        return self.opacity(1.0 - percentage)
    }
}
