//
//  SplashView.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    
    var body: some View {
        if isActive {
            BrewCalculatorView()
        } else {
            ZStack {
                Color.brewCardBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.brewPrimary)
                    
                    Text("BrewRatio")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.brewPrimary)
                    
                    Text("Perfect coffee, every time")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) {
                    opacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
