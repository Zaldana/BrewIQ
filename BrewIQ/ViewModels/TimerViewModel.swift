//
//  TimerViewModel.swift
//  BrewIQ
//
//  Created by Ruben Zaldana on 11/1/25.
//

import Foundation
import SwiftUI

@Observable
class TimerViewModel {
    var totalTime: TimeInterval
    var remainingTime: TimeInterval
    var isRunning = false
    var isPaused = false
    
    private var timer: Timer?
    
    init(duration: TimeInterval) {
        self.totalTime = duration
        self.remainingTime = duration
    }
    
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return (totalTime - remainingTime) / totalTime
    }
    
    var timeString: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        isPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 0.1
            } else {
                self.complete()
            }
        }
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = true
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        remainingTime = totalTime
    }
    
    func adjustTime(_ newTime: TimeInterval) {
        let wasRunning = isRunning
        reset()
        totalTime = newTime
        remainingTime = newTime
        if wasRunning {
            start()
        }
    }
    
    private func complete() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remainingTime = 0
        
        // Haptic feedback (iOS only)
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    deinit {
        timer?.invalidate()
    }
}
