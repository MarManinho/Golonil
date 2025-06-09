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
        "card1", "card2", "card2", "card3", "card3",
        "card4", "card4", "card5", "card5"
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
                                    .opacity(animatingCard == index ? 0.1 : 1.0) // Make original card nearly invisible during animation
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
                    Button(isFirstTeamDone ? "Start Game!" : "Continue to Next Team") {
                        handleContinue()
                    }
                    .buttonStyle(ImageButtonStyle(imageName: "button-basic"))
                    .padding(.bottom, 20)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: selectedCards.count == maxSelections)
                }
            }
            
            // Full-screen overlay for card detail view
            if let detailIndex = showingCardDetail {
                GeometryReader { geometry in
                    ZStack {
                        // Semi-transparent background
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .onTapGesture {
                                // Optional: dismiss on background tap
                            }
                        
                        VStack(spacing: 20) {
                            // Card display
                            ZStack {
                                // Front of card (image)
                                if !showingCardDescription {
                                    Image(shuffledCardImages.indices.contains(detailIndex) ? shuffledCardImages[detailIndex] : "card-template")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 180, height: 270)
                                        .cornerRadius(16)
                                        .shadow(color: .black.opacity(0.6), radius: 15, x: 0, y: 8)
                                }
                                
                                // Back of card (description)
                                if showingCardDescription {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .frame(width: 180, height: 270)
                                            .shadow(color: .black.opacity(0.6), radius: 15, x: 0, y: 8)
                                        
                                        VStack(spacing: 10) {
                                            Text("Card Details")
                                                .font(.custom("Kefa", size: 18))
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                            
                                            ScrollView {
                                                Text(cardDescriptions.indices.contains(detailIndex) ? cardDescriptions[detailIndex] : "No description available")
                                                    .font(.custom("Kefa", size: 14))
                                                    .foregroundColor(.black)
                                                    .multilineTextAlignment(.center)
                                                    .padding()
                                            }
                                        }
                                        .frame(width: 160, height: 250)
                                    }
                                }
                            }
                            .rotation3DEffect(
                                .degrees(showingCardDescription ? 180 : 0),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .animation(.easeInOut(duration: 0.8), value: showingCardDescription)
                            
                            // Action buttons
                            HStack(spacing: 20) {
                                // Learn About Card button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.8)) {
                                        showingCardDescription.toggle()
                                    }
                                }) {
                                    Text(showingCardDescription ? "Show Card" : "Learn About Card")
                                        .font(.custom("Kefa", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color.blue)
                                        .cornerRadius(25)
                                }
                                
                                // Continue button
                                Button(action: {
                                    continueToNextCard(currentIndex: detailIndex)
                                }) {
                                    Text("Continue to Next Card")
                                        .font(.custom("Kefa", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color.green)
                                        .cornerRadius(25)
                                }
                            }
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                }
                .transition(.opacity)
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
            
            // Add the card reveal with smooth animation
            withAnimation(.easeInOut(duration: 1.0)) {
                revealedCards.insert(index)
            }
            
            // Show detail view after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                animatingCard = nil
                showingCardDetail = index
                showingCardDescription = false // Reset to show card front
            }
        }
    }
    
    private func continueToNextCard(currentIndex: Int) {
        // Auto-select the current card
        if selectedCards.count < maxSelections {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedCards.insert(currentIndex)
            }
        }
        
        // Close detail view
        showingCardDetail = nil
        showingCardDescription = false
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
            withAnimation(.easeInOut(duration: 0.5)) {
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
