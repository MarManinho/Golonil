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
                VStack(spacing: 20) {
                    // Header with back button
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
                    
                    // Title
                    Text("Tutorials")
                        .font(.custom("Kefa", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.bottom, 10)
                    
                    // Expandable sections
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(1...5, id: \.self) { index in
                                ExpandableSection(title: "Test \(index)")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .tiledBackground()
        }
    }
}

struct ExpandableSection: View {
    let title: String
    @State private var isExpanded = false
    
    private let loremText = "**Lorem Ipsum** is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
    
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
                    Text(loremText)
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