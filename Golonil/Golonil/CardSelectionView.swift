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
    @State private var selectedCards: [String] = [] // Changed to array to maintain order
    @State private var selectedCardIndices: [Int] = [] // Track selected card indices for descriptions
    @State private var availableCardIndices: [Int] = [] // Track available cards
    @State private var shuffledCardImages: [String] = []
    @State private var showingCardDetail: Int? = nil // Track which card is showing in detail view
    @State private var animatingCardToSelection: String? = nil // Track card transitioning to selection
    @State private var allCardsRevealed: Bool = false // Track if we should show revealed cards view
    @State private var showingCardsChosen = false // Control CardsChosenView presentation
    @State private var centerCardIndex: Int = 0 // Track which card is in the center
    
    // Your 9 card images and descriptions - replace these with your actual image names and descriptions
    private let cardImageNames = [
        "card1", "card2", "card3", "card4", "card5",
        "card6", "card7", "card8", "card9"
    ]
    
    // Card real names mapping
    private let cardRealNames: [String: String] = [
        "card1": "Duel",
        "card2": "Empty Replay",
        "card3": "Empty Replay",
        "card4": "Nothing to Lose",
        "card5": "Nothing to Lose",
        "card6": "The Spy",
        "card7": "The Spy",
        "card8": "Two Birds, One Stone",
        "card9": "Two Birds, One Stone"
    ]
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

                        Text("Tap on each card to reveal and select it.\nChoose \(maxSelections) cards you want.")
                            .font(.custom("Kefa", size: 18))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)

                        Text("Selected: \(selectedCards.count)/\(maxSelections)")
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
                    // Circular scroll view for card selection - only show available cards
                    GeometryReader { outerProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) { // Reduced spacing from 10 to 5
                                ForEach(availableCardIndices, id: \.self) { index in
                                    GeometryReader { innerProxy in
                                        let midX = innerProxy.frame(in: .global).midX
                                        let screenMidX = outerProxy.size.width / 2
                                        let distanceFromCenter = abs(midX - screenMidX)
                                        let rotation = (midX - screenMidX) / -20
                                        
                                        // Enhanced scaling: center card is bigger, side cards are smaller
                                        let maxScale: CGFloat = 1.2 // Center card scale
                                        let minScale: CGFloat = 0.75 // Side cards scale
                                        let scaleRange = maxScale - minScale
                                        let normalizedDistance = min(distanceFromCenter / 200, 1.0) // Adjust 200 to control transition distance
                                        let scale = maxScale - (scaleRange * normalizedDistance)
                                        
                                        CardView(
                                            cardIndex: index,
                                            imageName: "card-template", // Always show template for unrevealed cards
                                            onTap: {
                                                handleCardTap(index: index)
                                            }
                                        )
                                        .rotation3DEffect(
                                            .degrees(Double(rotation)),
                                            axis: (x: 0, y: 1, z: 0)
                                        )
                                        .scaleEffect(scale)
                                    }
                                    .frame(width: 150, height: 220)
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .frame(height: 260)
                } else {
                    // Show only revealed cards with descriptions below
                    revealedCardsView()
                }

                                
                Spacer()
                
                // Selected cards display at bottom (only during selection phase)
                if !selectedCards.isEmpty && !allCardsRevealed {
                    VStack(spacing: 12) {
                        Text("Your Selected Cards")
                            .font(.custom("Kefa", size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        HStack(spacing: 8) {
                            ForEach(selectedCards, id: \.self) { cardName in
                                Image(cardName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(currentTeam == team1Name ? team1Color : team2Color, lineWidth: 2)
                                    )
                                    .scaleEffect(animatingCardToSelection == cardName ? 0.8 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: animatingCardToSelection == cardName)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                // Continue button (appears when 5 cards are selected)
                if selectedCards.count == maxSelections {
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
                    .animation(.easeInOut(duration: 0.3), value: selectedCards.count == maxSelections)
                }
            }
            
            // Full-screen overlay for card detail view
            if let detailIndex = showingCardDetail {
                GeometryReader { geometry in
                    ZStack {
                        // Background
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                            .onTapGesture {
                                // Prevent dismissing by tap, let animation complete
                            }
                        
                        VStack(spacing: 20) {
                            // Large card display with glow effect
                            ZStack {
                                // Glow effect background
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                (currentTeam == team1Name ? team1Color : team2Color).opacity(0.4),
                                                (currentTeam == team1Name ? team1Color : team2Color).opacity(0.1),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 50,
                                            endRadius: 150
                                        )
                                    )
                                    .frame(width: 280, height: 400)
                                
                                // Main card with revealed image
                                Image(shuffledCardImages.indices.contains(detailIndex) ? shuffledCardImages[detailIndex] : "card-template")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 240, height: 360)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.6), radius: 20, x: 0, y: 10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.4),
                                                        (currentTeam == team1Name ? team1Color : team2Color).opacity(0.6),
                                                        Color.white.opacity(0.4)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                    )
                            }
                            
                            // Card title with enhanced styling
                            VStack(spacing: 8) {
                                Text(shuffledCardImages.indices.contains(detailIndex) ?
                                     (cardRealNames[shuffledCardImages[detailIndex]] ?? "Unknown Card") :
                                     "Unknown Card")
                                    .font(.custom("Kefa", size: 28))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
                                
                                Text("Selected!")
                                    .font(.custom("Kefa", size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundColor((currentTeam == team1Name ? team1Color : team2Color))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.9))
                                    )
                            }
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .scaleEffect(showingCardDetail != nil ? 1.0 : 0.3)
                        .opacity(showingCardDetail != nil ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5), value: showingCardDetail != nil)
                    }
                }
                .transition(.opacity)
                .zIndex(1000)
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
    
    private func setupRandomCards() {
        // Shuffle the card images randomly
        shuffledCardImages = cardImageNames.shuffled()
        // Initialize available card indices (0 to 8)
        availableCardIndices = Array(0..<totalCards)
    }
    
    private func handleCardTap(index: Int) {
        // Check if we've already selected max cards
        if selectedCards.count >= maxSelections {
            return
        }
        
        // Get the actual card name from shuffled array
        let selectedCardName = shuffledCardImages.indices.contains(index) ? shuffledCardImages[index] : "card-template"
        
        // Start fade in animation (0.5 seconds)
        withAnimation(.easeInOut(duration: 0.5)) {
            showingCardDetail = index
        }
        
        // After 0.5 seconds, start fade out and move to selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                // Hide detail view (fade out)
                showingCardDetail = nil
                
                // Add to selected cards
                selectedCards.append(selectedCardName)
                selectedCardIndices.append(index) // Track index for descriptions
                
                // Set animation state for the new card
                animatingCardToSelection = selectedCardName
                
                // Remove from available cards
                availableCardIndices.removeAll { $0 == index }
                
                // Check if all cards are selected
                if selectedCards.count == maxSelections {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            allCardsRevealed = true
                        }
                    }
                }
            }
            
            // Reset animation state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                animatingCardToSelection = nil
            }
        }
    }
    
    private func saveCurrentTeamCards() {
        if currentTeam == team1Name {
            team1Cards = selectedCards
        } else {
            team2Cards = selectedCards
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
                selectedCardIndices.removeAll()
                showingCardDetail = nil
                animatingCardToSelection = nil
                allCardsRevealed = false
                
                // Reset available cards for the second team and reshuffle
                setupRandomCards()
            }
        } else {
            // Both teams have selected, proceed to game
            showingGameExplanation = true
        }
    }
    
    // Show only revealed cards with descriptions below
    // Show only revealed cards with descriptions below
        private func revealedCardsView() -> some View {
            VStack(spacing: 20) {
                // Cards scroll view without text
                GeometryReader { outerProxy in
                    ScrollViewReader { scrollProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                ForEach(Array(selectedCardIndices.enumerated()), id: \.offset) { enumeration in
                                    let (arrayIndex, cardIndex) = enumeration
                                    GeometryReader { innerProxy in
                                        let midX = innerProxy.frame(in: .global).midX
                                        let screenMidX = outerProxy.size.width / 2
                                        let distanceFromCenter = abs(midX - screenMidX)
                                        let rotation = (midX - screenMidX) / -20
                                        
                                        // Calculate opacity for description based on distance from center
                                        let maxDistance: CGFloat = 100
                                        let opacity = max(0, 1 - (distanceFromCenter / maxDistance))
                                        
                                        // Same scaling as selection view
                                        let maxScale: CGFloat = 1
                                        let minScale: CGFloat = 0.75
                                        let scaleRange = maxScale - minScale
                                        let normalizedDistance = min(distanceFromCenter / 200, 1.0)
                                        let scale = maxScale - (scaleRange * normalizedDistance)
                                        
                                        // Update center card index when close enough to center
                                        let _ = {
                                            if distanceFromCenter < 50 {
                                                DispatchQueue.main.async {
                                                    if centerCardIndex != arrayIndex {
                                                        centerCardIndex = arrayIndex
                                                    }
                                                }
                                            }
                                        }()
                                        
                                        // Card image only
                                        Image(selectedCards.indices.contains(arrayIndex) ? selectedCards[arrayIndex] : "card-template")
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
                                            .rotation3DEffect(
                                                .degrees(Double(rotation)),
                                                axis: (x: 0, y: 1, z: 0)
                                            )
                                            .scaleEffect(scale)
                                            .id(arrayIndex)
                                    }
                                    .frame(width: 150, height: 220)
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                }
                .frame(height: 240)
                
                // Description rectangle
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.brown.opacity(0.7))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .frame(height: 200)
                    
                    VStack(spacing: 15) {
                        // Card name
                        if selectedCards.indices.contains(centerCardIndex) {
                            Text(cardRealNames[selectedCards[centerCardIndex]] ?? "Unknown Card")
                                .font(.custom("Kefa", size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                        }
                        
                        // Card description
                        if selectedCardIndices.indices.contains(centerCardIndex) {
                            let cardIndex = selectedCardIndices[centerCardIndex]
                            Text(cardDescriptions.indices.contains(cardIndex) ? cardDescriptions[cardIndex] : "No description available")
                                .font(.custom("Kefa", size: 16))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                                .padding(.horizontal, 20)
                                .transition(.opacity)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .padding(.horizontal, 20)
            }
        }
}

struct CardView: View {
    let cardIndex: Int
    let imageName: String
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Card template
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 200)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            
            // Tap indicator
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
                    .opacity(0.9)
            }
            .padding(.bottom, 20)
        }
        .onTapGesture {
            onTap()
        }
    }
}
