//
//  TutorialsView.swift
//  Golonil
//
//  Created on 09/06/25.
//

import SwiftUI

struct TutorialsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Header with back button - positioned separately
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .padding()
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    .padding(.top)
                    
                    // Content moved higher with negative spacing
                    VStack(spacing: 20) {
                        // Title
                        Text("Tutorials")
                            .font(.custom("Kefa", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.bottom, 10)
                        
                        // Expandable sections
                        ScrollView {
                            VStack(spacing: 15) {
                                ExpandableSection(title: "What is Golonil?", index: 1)
                                ExpandableSection(title: "Basics of Golonil", index: 2)
                                ExpandableSection(title: "The Hiders Team: First Steps", index: 3)
                                ExpandableSection(title: "The Guessers Team: First Steps", index: 4)
                                ExpandableSection(title: "Additional Rules", index: 5)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                    .padding(.top, -30) // Move content up by 30 points
                }
            }
            .tiledBackground()
        }
    }
}

struct ExpandableSection: View {
    let title: String
    let index: Int
    @State private var isExpanded = false
    
    private var contentText: String {
        if index == 1 {
            return "Welcome to Golonil! Golonil is a fun group game where you are going to Trick People's Minds with your Hands!   It's based on an old Persian game named \"Gol ya Pooch\" that is being played for hundreds of years in Iran, and still being played to this day!   It's a fun, competitive and collaborative game to play with friends and family, with only your hands, and a small stone, marble, or even a curled up piece of paper in the shape of a ball to hide!"
        } else if index == 2 {
            return "Golonil is played 3 vs 3, with each team having a Master who is sitting in the middle, and two other teammates.   There is one Hiders Team, who try to Hide the ball with their tricks in their sleeves, and there is a Guessers Team, who try to find the ball by correctly emptying the hands they think are empty and finding the ball, or guessing the ball right away and getting 2 points!   So it depends how well the Hiders Team are doing their tricks, and how well the Guessing Team is guessing the empty hands!   If the Guessers team find the Gol, now they will be the Hiders Team and the other team will be trying to find the ball for the next round!   A Coin Flip before start of the game, decides which team has the ball first! Then, each team will be given 9 random cards to choose from, where they should choose 5 cards. These cards have special abilities that you can use to find the ball easier!"
        } else if index == 3 {
            return "The Master of the Team that won the coin flip will start the game by doing his tricks.   Then, the Master will fill in his teammates' hands (one hand per each teammate). The Master can do a final trick and after, will present the closed hands to the other team.   The teammates will now fill in their empty hand one by one and like the Master, present their hands to other team. Now it's Guessers Team turn!"
        } else if index == 4 {
            return "The Guessers team can have time to discuss their strategies of finding the Gol and which player in their mind has the Gol, or which hand is empty.   They have 3 chances of asking the other team for an \"Empty Flip\", in which the player that was asked to replay, will show the empty hand (if both are empty, they will show one hand by their choice) and will start again doing tricks by filling the empty hand until they finish the trick and again present the closed hands to the other team.   The Guessers team can start the game by guessing the hand with the Gol right away, which has 2 points, or can start by emptying the hand that they think is empty (Finding the ball with emptying even one hand doesn't have a point, it will only wins the ball for the Guessers team for the next round) or they can start the game by asking someone for Empty Flip.   To do each of these actions that will start the timer of the game, the Guessers team will tap on the Bell to start the timer, which is 3 minutes. The Guessers team can also use their cards based on their abilities that helps them find the Gol faster!"
        } else if index == 5 {
            return "Duel Mode:\n\nIf during the tricks of the Hiders Team, the ball falls down from their hands, a Duel will be played.\n\nDuel is between the person who let go of the ball while doing the tricks, and one chosen person of the Guessers Team.\n\nThe Hiders Team's member will try to do the tricks and hide the ball again, but now he is alone and only have their own two hands!\n\nWhen they finish, It's the Guesser Team's member turn. If they find the Gol, the Guessers Team will have the ball for the next round, but without getting any point.\n\nIf they don't manage to find the ball, the Hiders Team will continue to have the ball for the next round, still, not scoring any point."
        } else {
            return "**Lorem Ipsum** is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header section (always visible)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.custom("Kefa", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: isExpanded ? 15 : 15)
                        .fill(Color.brown.opacity(0.8))
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expandable content
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Text(contentText)
                        .font(.custom("Kefa", size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                        )
                        .padding(.top, 5)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .padding(.horizontal, 5)
    }
}

#Preview {
    TutorialsView()
}
