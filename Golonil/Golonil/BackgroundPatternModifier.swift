//
//  BackgroundPatternModifier.swift
//  Goalonil
//
//  Created by Mukhtaram Sulaimonov on 21/05/25.
//

import SwiftUI

extension View {
    func tiledBackground() -> some View {
        ZStack {
            Image("BackgroundPattern")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()
            self
        }
    }
}
