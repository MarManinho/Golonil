import SwiftUI

struct CardSelectionView: View {
    var team1Name: String
    var team2Name: String
    var team1Color: Color
    var team2Color: Color
    var startingTeam: String
    
    // Add these parameters to handle team card storage and progression
    @Binding var team1Cards: [String]
    @Binding var team2Cards: [String]
    @State private var currentTeam: String
    @State private var isFirstTeamDone: Bool = false
    @State private var showingGameExplanation = false

    @Environment(\.dismiss) var dismiss
    @State private var selectedCards: Set<Int> = []
    @State private var shuffledCardImages: [String] = []
    @State private var revealedCards: Set<Int> = [] // Track which cards are revealed
    @State private var animatingCard: Int? = nil // Track which card is currently animating
    @State private var showingCardDetail: Int? = nil // Track which card is showing in detail view
    
    // States for the modified flow
    @State private var allCardsRevealed: Bool = false
    @State private var autoRevealInProgress: Bool = false
    
    // Your 9 card images and descriptions - replace these with your actual image names and descriptions
    private let cardImageNames = [
        "card1", "card2", "card3", "card4", "card5",
        "card6", "card7", "card8", "card9"
    ]
    
    // Card descriptions - you'll provide these
    private let cardDescriptions = [
        "A One vs One Duel will be done between one member of each team. The winner will get the ball for the next round.",
        "The Guessing team can use 3 more Empty Replays on the other team with this card.",
        "The Guessing team can use 3 more Empty Replays on the other team with this card.",
        "The Guessing team can guess the hand with Goal. If they fail, the game continues.",
        "The Guessing team can guess the hand with Goal. If they fail, the game continues.",
        "Guessing team can ask one question from the other team. The player who is questioned should tell the truth.",
        "Guessing team can ask one question from the other team. The player who is questioned should tell the truth.",
        "By correctly emptying one hand, the Master of the opposing team is required to empty another hand of the team.",
        "By correctly emptying one hand, the Master of the opposing team is required to empty another hand of the team."
    ]
    
    private let totalCards = 9
    private let maxSelections = 5
    
    // Initialize currentTeam
    init(team1Name: String, team2Name: String, team1Color: Color, team2Color: Color,
         startingTeam: String, team1Cards: Binding<[String]>, team2Cards: Binding<[String]>) {
        self.team1Name = team1Name
        self.team2Name = team2Name
        self.team1Color = team1Color
        self.team2Color = team2Color
        self.startingTeam = startingTeam
        self._team1Cards = team1Cards
        self._team2Cards = team2Cards
        self._currentTeam = State(initialValue: startingTeam)
    }

    var body: some View {
        ZStack {
            Image("BackgroundPattern")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .padding()
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // Titles
                VStack(spacing: 10) {
                    Text("Team \(currentTeam)")
                        .font(.custom("Kefa", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(currentTeam == team1Name ? team1Color : team2Color)

                    if !allCardsRevealed {
                        Text("Choose your Cards")
                            .font(.custom("Kefa", size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        Text("Tap on each card to reveal it.\nChoose \(maxSelections) cards you want.")
                            .font(.custom("Kefa", size: 18))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)

                        Text("Revealed: \(revealedCards.count)/\(maxSelections)")
                            .font(.custom("Kefa", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    } else {
                        Text("Your Selected Cards")
                            .font(.custom("Kefa", size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        Text("These are the cards you'll use in the game")
                            .font(.custom("Kefa", size: 18))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, 10)

                if !allCardsRevealed {
                    // Original circular scroll view for card selection
                    GeometryReader { outerProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(0..<totalCards, id: \.self) { index in
                                    GeometryReader { innerProxy in
                                        let midX = innerProxy.frame(in: .global).midX
                                        let screenMidX = outerProxy.size.width / 2
                                        let rotation = (midX - screenMidX) / -20
                                        let scale = max(0.8, 1.0 - abs(midX - screenMidX) / 500)
                                        
                                        CardView(
                                            cardIndex: index,
                                            imageName: revealedCards.contains(index) ?
                                                      (shuffledCardImages.indices.contains(index) ? shuffledCardImages[index] : "card-template") :
                                                      "card-template",
                                            isRevealed: revealedCards.contains(index),
                                            isSelected: selectedCards.contains(index),
                                            isAnimating: animatingCard == index,
                                            onTap: {
                                                handleCardTap(index: index)
                                            }
                                        )
                                        .rotation3DEffect(
                                            .degrees(Double(rotation)),
                                            axis: (x: 0, y: 1, z: 0)
                                        )
                                        .scaleEffect(scale)
                                        .opacity(animatingCard == index ? 0.2 : 1.0)
                                    }
                                    .frame(width: 150, height: 220)
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .frame(height: 260)
                } else {
                    // Show only revealed cards with descriptions
                    revealedCardsView()
                }

                Spacer()
                
                if !allCardsRevealed {
                    // Selected cards display at bottom during selection phase
                    if !selectedCards.isEmpty {
                        VStack {
                            Text("Your Selected Cards")
                                .font(.custom("Kefa", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            HStack {
                                ForEach(Array(selectedCards).sorted(), id: \.self) { cardIndex in
                                    Image(shuffledCardImages.indices.contains(cardIndex) ? shuffledCardImages[cardIndex] : "card-template")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                        .cornerRadius(8)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: selectedCards)
                        }
                        .padding(.bottom, 20)
                    }
                }
                
                // Continue button (appears when 5 cards are revealed)
                if revealedCards.count == maxSelections {
                    Button(action: {
                        handleContinue()
                    }) {
                        Image(isFirstTeamDone ? "startButton" : "continueButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 80)
                    }
                    .padding(.bottom, 20)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: revealedCards.count == maxSelections)
                }
            }
            
            // Full-screen overlay for card detail view (simplified - just show card briefly)
            if let detailIndex = showingCardDetail {
                GeometryReader { geometry in
                    ZStack {
                        // Subtle background
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 15) {
                            // Card display
                            ZStack {
                                // Glow effect background
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                (currentTeam == team1Name ? team1Color : team2Color).opacity(0.3),
                                                (currentTeam == team1Name ? team1Color : team2Color).opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 220, height: 320)
                                    .blur(radius: 10)
                                
                                // Main card
                                Image(shuffledCardImages.indices.contains(detailIndex) ? shuffledCardImages[detailIndex] : "card-template")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 300)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.8), radius: 20, x: 0, y: 10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.3), Color.clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                            }
                            
                            // Card title
                            Text("Power Card #\(detailIndex + 1)")
                                .font(.custom("Kefa", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(4000)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingGameExplanation) {
            GameExplanationView(
                team1Name: team1Name,
                team2Name: team2Name,
                team1Color: team1Color,
                team2Color: team2Color,
                ballTeam: startingTeam,
                guessingTeam: startingTeam == team1Name ? team2Name : team1Name,
                team1Cards: $team1Cards,
                team2Cards: $team2Cards
            )
        }
        .onAppear {
            setupRandomCards()
        }
    }
    
    // Show only revealed cards with descriptions below
    private func revealedCardsView() -> some View {
        let revealedCardIndices = Array(revealedCards).sorted()
        
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(revealedCardIndices, id: \.self) { cardIndex in
                    VStack(spacing: 15) {
                        // Card image
                        Image(shuffledCardImages.indices.contains(cardIndex) ? shuffledCardImages[cardIndex] : "card-template")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 200)
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                (currentTeam == team1Name ? team1Color : team2Color),
                                                (currentTeam == team1Name ? team1Color : team2Color).opacity(0.6)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                        
                        // Card description
                        VStack(spacing: 8) {
                            Text("Power Card #\(cardIndex + 1)")
                                .font(.custom("Kefa", size: 16))
                                .fontWeight(.bold)
                                .foregroundColor(currentTeam == team1Name ? team1Color : team2Color)
                            
                            Text(cardDescriptions.indices.contains(cardIndex) ? cardDescriptions[cardIndex] : "No description available")
                                .font(.custom("Kefa", size: 12))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                                .lineSpacing(2)
                                .frame(width: 140)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(width: 160)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 350)
    }
    
    private func setupRandomCards() {
        // Shuffle the card images randomly
        shuffledCardImages = cardImageNames.shuffled()
    }
    
    private func handleCardTap(index: Int) {
        // Prevent interaction during auto-reveal
        if autoRevealInProgress {
            return
        }
        
        // If card is not revealed yet, reveal it
        if !revealedCards.contains(index) {
            // Check if we've already revealed 5 cards
            if revealedCards.count >= maxSelections {
                return
            }
            
            autoRevealInProgress = true
            
            // Start animation
            animatingCard = index
            
            // Add the card reveal and auto-select
            withAnimation(.easeInOut(duration: 0.4)) {
                revealedCards.insert(index)
                selectedCards.insert(index)
            }
            
            // Show detail view briefly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                animatingCard = nil
                showingCardDetail = index
                
                // Show card for 1 second, then close
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingCardDetail = nil
                        autoRevealInProgress = false
                        
                        // Check if all cards are revealed
                        if revealedCards.count == maxSelections {
                            // Switch to revealed cards view
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    allCardsRevealed = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveCurrentTeamCards() {
        let selectedCardNames = Array(selectedCards).sorted().compactMap { index in
            shuffledCardImages.indices.contains(index) ? shuffledCardImages[index] : nil
        }
        
        if currentTeam == team1Name {
            team1Cards = selectedCardNames
        } else {
            team2Cards = selectedCardNames
        }
    }
    
    private func handleContinue() {
        saveCurrentTeamCards()
        
        if !isFirstTeamDone {
            // Switch to the other team
            withAnimation(.easeInOut(duration: 0.4)) {
                currentTeam = currentTeam == team1Name ? team2Name : team1Name
                isFirstTeamDone = true
                selectedCards.removeAll()
                revealedCards.removeAll()
                animatingCard = nil
                showingCardDetail = nil
                allCardsRevealed = false
                autoRevealInProgress = false
                
                // Reshuffle cards for the second team
                setupRandomCards()
            }
        } else {
            // Both teams have selected, proceed to game
            showingGameExplanation = true
        }
    }
}

struct CardView: View {
    let cardIndex: Int
    let imageName: String
    let isRevealed: Bool
    let isSelected: Bool
    let isAnimating: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Card back/front
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 200)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.green : Color.clear, lineWidth: 3)
                )
            
            // Selection indicator
            if isSelected && !isAnimating {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(8)
            }
            
            // Tap indicator for unrevealed cards
            if !isRevealed && !isAnimating {
                VStack {
                    Spacer()
                    Text("TAP TO REVEAL")
                        .font(.custom("Kefa", size: 12))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .opacity(0.8)
                }
                .padding(.bottom, 20)
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}
