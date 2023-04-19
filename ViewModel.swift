import SwiftUI
import Foundation 

// Runs the timer 

extension ContentView {
    final class ViewModel: ObservableObject {
        @Published var isActive = false
        @Published var showingPositiveAlert = false
        @Published var showingNegativeAlert = false
        @Published var time: String = "25:00"
        @Published var isBreak = false 
        @Published var minutes: Float = 25.0 {
            didSet {
                self.time = "\(Int(minutes)):00"
            }
        } 
        
        private var initalTime = 0
        private var endDate = Date() 
        
        // Function for the start button
        func start(minutes: Float) {
            self.initalTime = Int(minutes)
            self.endDate = Date() 
            self.isActive = true
            self.endDate = Calendar.current.date(byAdding: .minute, value: Int(minutes), to: endDate)!
            
        }
        
        // Function for the reset button 
        func reset() {
            self.minutes = Float(initalTime)
            self.isActive = false
            self.isBreak = false
            self.time = "25:00"
            self.showingNegativeAlert = true
        }
        
        func updateCountdown(){
            guard isActive else { return }
            
            // Gets the current date and makes the time difference calculation
            let now = Date()
            let diff = endDate.timeIntervalSince1970 - now.timeIntervalSince1970
            
            // Checks that the countdown is not <= 0
            if diff <= 0 {
                self.isActive = false
                self.time = "0:00"
                self.showingPositiveAlert = true
                if (self.isBreak == true) {
                    self.isBreak = false
                    self.minutes = 25
                    self.time = "25:00"
                } else {
                    self.isBreak = true
                    self.minutes = 5
                    self.time = "5:00"
                }
                return
            }
            
            // Turns the time difference calculation into sensible data and formats it
            let date = Date(timeIntervalSince1970: diff)
            let calendar = Calendar.current
            let minutes = calendar.component(.minute, from: date)
            let seconds = calendar.component(.second, from: date)
            
            // Updates the time string with the formatted time
            self.minutes = Float(minutes)
            self.time = String(format:"%d:%02d", minutes, seconds)
        }        
        
    }
}
