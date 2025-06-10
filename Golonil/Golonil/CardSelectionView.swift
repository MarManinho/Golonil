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
    @State private var showingCardDescription: Bool = false // Track if showing description side
    
    // Your 9 card images and descriptions - replace these with your actual image names and descriptions
    private let cardImageNames = [
        "card1", "card2", "card3", "card4", "card5",
        "card6", "card7", "card8", "card9"
    ]
    
    // Card descriptions - you'll provide these
    private let cardDescriptions = [
        "A One vs One Duel will be done between one member of each team. The winner will get the ball for the next round.",
        "The Guessing team can use 3 more Empty Replays  on the other team with this card.",
        "The Guessing team can use 3 more Empty Replays  on the other team with this card.",
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

                    Text("Choose your Cards")
                        .font(.custom("Kefa", size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Text("Tap on each card to reveal it.\nChoose \(maxSelections) cards you want.")
                        .font(.custom("Kefa", size: 18))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)

                    Text("Selected: \(selectedCards.count)/\(maxSelections)")
                        .font(.custom("Kefa", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
                .padding(.bottom, 20)

                Spacer()

                // Circular Scroll View
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
                                    .opacity(animatingCard == index ? 0.2 : 1.0) // Slightly less transparent during animation
                                }
                                .frame(width: 150, height: 220)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .frame(height: 260)

                Spacer()
                
                // Selected cards display
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
                
                // Continue button (appears when 5 cards are selected)
                if selectedCards.count == maxSelections {
                    Button(action: {
                        handleContinue()
                    }) {
                        Image(isFirstTeamDone ? "startButton" : "continueButton")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 80) // adjust width/height to match your design
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
                        // Subtle background with larger tap area
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .onTapGesture {
                                // Continue to next card when tapping anywhere on background
                                continueToNextCard(currentIndex: detailIndex)
                            }
                        
                        VStack(spacing: 15) {
                            // Close button
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        showingCardDetail = nil
                                        showingCardDescription = false
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                            
                            // Card display container
                            VStack(spacing: 15) {
                                ZStack {
                                    // Front of card (image)
                                    if !showingCardDescription {
                                        VStack(spacing: 15) {
                                            // Card image with enhanced styling
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
                                    }
                                    
                                    // Back of card (description)
                                    if showingCardDescription {
                                        VStack(spacing: 20) {
                                            // Description card with glassmorphism effect
                                            ZStack {
                                                // Background with blur
                                                RoundedRectangle(cornerRadius: 25)
                                                    .fill(.ultraThinMaterial)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .fill(
                                                                LinearGradient(
                                                                    colors: [
                                                                        Color.white.opacity(0.2),
                                                                        Color.white.opacity(0.1)
                                                                    ],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                )
                                                            )
                                                    )
                                                    .frame(width: 280, height: 350)
                                                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 25)
                                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                    )
                                                
                                                VStack(spacing: 20) {
                                                    // Icon and title
                                                    VStack(spacing: 10) {
                                                        Image(systemName: "info.circle.fill")
                                                            .font(.system(size: 30))
                                                            .foregroundColor(currentTeam == team1Name ? team1Color : team2Color)
                                                        
                                                        Text("Card Details")
                                                            .font(.custom("Kefa", size: 22))
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.white)
                                                    }
                                                    
                                                    // Divider
                                                    Rectangle()
                                                        .fill(Color.white.opacity(0.3))
                                                        .frame(width: 100, height: 1)
                                                    
                                                    // Description text
                                                    ScrollView {
                                                        Text(cardDescriptions.indices.contains(detailIndex) ? cardDescriptions[detailIndex] : "No description available")
                                                            .font(.custom("Kefa", size: 16))
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.center)
                                                            .lineSpacing(4)
                                                            .padding(.horizontal, 20)
                                                    }
                                                    .frame(maxHeight: 200)
                                                }
                                                .frame(width: 260, height: 330)
                                            }
                                        }
                                    }
                                }
                                .animation(.easeInOut(duration: 0.3), value: showingCardDescription)
                            }
                            
                            // Enhanced action buttons with larger tap areas
                            HStack(spacing: 25) {
                                // Card Info/Show Card button with larger tap area
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showingCardDescription.toggle()
                                    }
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: showingCardDescription ? "photo" : "info.circle")
                                            .font(.system(size: 18, weight: .semibold))
                                        Text(showingCardDescription ? "Show Card" : "Card Info")
                                            .font(.custom("Kefa", size: 16))
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 25)
                                    .padding(.vertical, 15)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(25)
                                    .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .scaleEffect(showingCardDescription ? 0.95 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: showingCardDescription)
                                
                                // Next Card button
                                Button(action: {
                                    continueToNextCard(currentIndex: detailIndex)
                                }) {
                                    HStack(spacing: 10) {
                                        Text("Next Card")
                                            .font(.custom("Kefa", size: 16))
                                            .fontWeight(.semibold)
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 25)
                                    .padding(.vertical, 15)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.green, Color.green.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(25)
                                    .shadow(color: Color.green.opacity(0.4), radius: 10, x: 0, y: 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 40)
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
                ballTeam: startingTeam, // The starting team has the ball first
                guessingTeam: startingTeam == team1Name ? team2Name : team1Name, // The other team is guessing
                team1Cards: $team1Cards, // Pass the card bindings
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
    }
    
    private func handleCardTap(index: Int) {
        // If card is not revealed yet, reveal it first
        if !revealedCards.contains(index) {
            // Check if we've already revealed 5 cards
            if revealedCards.count >= maxSelections {
                // Don't allow revealing more than 5 cards
                return
            }
            
            // Start animation
            animatingCard = index
            
            // Add the card reveal with faster animation
            withAnimation(.easeInOut(duration: 0.4)) {
                revealedCards.insert(index)
            }
            
            // Show detail view after animation completes - much faster
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                animatingCard = nil
                showingCardDetail = index
                showingCardDescription = false // Reset to show card front
            }
        }
    }
    
    private func continueToNextCard(currentIndex: Int) {
        // Auto-select the current card
        if selectedCards.count < maxSelections {
            withAnimation(.easeInOut(duration: 0.25)) {
                selectedCards.insert(currentIndex)
            }
        }
        
        // Close detail view
        withAnimation(.easeInOut(duration: 0.25)) {
            showingCardDetail = nil
            showingCardDescription = false
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
                showingCardDescription = false
                
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
