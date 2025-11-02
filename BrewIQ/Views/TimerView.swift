//
//  TimerView.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import SwiftUI

struct TimerView: View {
    @State var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Brew Timer")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Circular progress ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(Color.brewPrimary, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: viewModel.progress)
                
                VStack(spacing: 8) {
                    Text(viewModel.timeString)
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    if viewModel.remainingTime == 0 {
                        Text("Complete!")
                            .font(.headline)
                            .foregroundStyle(Color.brewAccent)
                    }
                }
            }
            
            // Controls
            HStack(spacing: 30) {
                Button(action: { viewModel.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.gray)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    if viewModel.isRunning {
                        viewModel.pause()
                    } else {
                        viewModel.start()
                    }
                }) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundStyle(Color.brewTextOnPrimary)
                        .frame(width: 80, height: 80)
                        .background(Color.brewPrimary)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        TimerView(viewModel: TimerViewModel(duration: 240))
    }
}
