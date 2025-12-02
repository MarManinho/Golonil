//
//  ImageButtonStyle.swift
//  Goalonil
//
//  Created by Mukhtaram Sulaimonov on 21/05/25.
//

import SwiftUI

struct ImageButtonStyle: ButtonStyle {
    var imageName: String
    var height: CGFloat = 180
    var width: CGFloat? = nil // Optional fixed width

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Image(imageName)
                .resizable(
                    capInsets: EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40),
                    resizingMode: .stretch
                )
                .frame(width: width, height: height)
                .cornerRadius(12)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)

            configuration.label
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
        }
        .frame(width: width, height: height)
    }
}

