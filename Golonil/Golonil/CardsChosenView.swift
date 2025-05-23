//
//  CardsChosenView.swift
//  Goalonil
//
//  Created by Mukhtaram Sulaimonov on 22/05/25.
//

import SwiftUI

struct CardsChosenView: View {
    let teamName: String
    let teamColor: Color
    let selectedCards: [String] // names of image assets

    var body: some View {
        ZStack {
            Color.clear
                .tiledBackground()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Team \(teamName)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(teamColor)

                Text("You’ve Chosen Your Cards!")
                    .font(.largeTitle)
                    .fontWeight(.black)

                Text("Swipe to view your selected cards.")
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(selectedCards, id: \.self) { cardName in
                            Image(cardName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 180)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                Button(action: {
                    // Navigate to the next screen
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(teamColor)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .padding(.top, 60)
        }
    }
}
