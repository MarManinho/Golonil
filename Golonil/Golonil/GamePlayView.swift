//
//  GamePlayView.swift
//  Golonil
//
//  Created by Mukhtaram Sulaimonov on 08/06/25.
//
import SwiftUI

struct GamePlayView: View {
    var team1Name: String
    var team2Name: String
    var team1Color: Color
    var team2Color: Color
    var ballTeam: String // Team that has the ball
    var guessingTeam: String // Team that is guessing
    var currentRound: Int
    
    @Environment(\.dismiss) var dismiss
    @State private var team1Score: Int = 0
    @State private var team2Score: Int = 0
    @State private var timeRemaining: Int = 180 // 3:00 in seconds
    @State private var timer: Timer?
    @State private var isGameStarted: Bool = false
    @State private var bellPressed: Bool = false
    
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
                    
                    // Round indicator and scores
                    HStack {
                        // Team 1 Score
                        Text("\(team1Score)")
                            .font(.custom("Kefa", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(team1Color)
                        
                        Spacer()
                        
                        // Round and Timer in center
                        VStack(spacing: 5) {
                            HStack(spacing: 10) {
                                // Round indicator
                                HStack(spacing: 5) {
                                    Text("Round \(currentRound)")
                                        .font(.custom("Kefa", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    // Small circle indicator
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 8, height: 8)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(15)
                                
                                // Timer
                                Text(formattedTime)
                                    .font(.custom("Kefa", size: 24))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(15)
                            }
                            
                            // Guessing team indicator
                            Text("Team \(guessingTeam) is guessing")
                                .font(.custom("Kefa", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(guessingTeam == team1Name ? team1Color : team2Color)
                        }
                        
                        Spacer()
                        
                        // Team 2 Score
                        Text("\(team2Score)")
                            .font(.custom("Kefa", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(team2Color)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 30)
                
                Spacer()
                
                // Main content area
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
                        Image(systemName: "bell.fill") // Replace with your bell image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .scaleEffect(bellPressed ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: bellPressed)
                }
                
                Spacer()
                
                // Bottom area for potential score buttons or actions
                if isGameStarted {
                    VStack(spacing: 20) {
                        Text("Game in Progress...")
                            .font(.custom("Kefa", size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        // Score buttons (you can customize these based on game rules)
                        HStack(spacing: 20) {
                            Button("Team \(team1Name) +1") {
                                addScore(team: 1, points: 1)
                            }
                            .buttonStyle(ScoreButtonStyle(color: team1Color))
                            
                            Button("Team \(team2Name) +1") {
                                addScore(team: 2, points: 1)
                            }
                            .buttonStyle(ScoreButtonStyle(color: team2Color))
                        }
                        
                        HStack(spacing: 20) {
                            Button("Team \(team1Name) +2") {
                                addScore(team: 1, points: 2)
                            }
                            .buttonStyle(ScoreButtonStyle(color: team1Color))
                            
                            Button("Team \(team2Name) +2") {
                                addScore(team: 2, points: 2)
                            }
                            .buttonStyle(ScoreButtonStyle(color: team2Color))
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func handleBellTap() {
        bellPressed = true
        
        // Reset bell animation after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            bellPressed = false
        }
        
        if !isGameStarted {
            startGame()
        } else {
            // Bell can be used during game for various actions
            // Implement based on your game rules
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
                // Time's up
                stopTimer()
                // Handle end of round
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
            // Go back to previous screen
            dismiss()
        }
    }
    
    private func addScore(team: Int, points: Int) {
        if team == 1 {
            team1Score += points
        } else {
            team2Score += points
        }
    }
}

// Custom button style for score buttons
struct ScoreButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom("Kefa", size: 16))
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Preview
struct GamePlayView_Previews: PreviewProvider {
    static var previews: some View {
        GamePlayView(
            team1Name: "Astra",
            team2Name: "Lions",
            team1Color: .blue,
            team2Color: .red,
            ballTeam: "Astra",
            guessingTeam: "Lions",
            currentRound: 3
        )
    }
}
