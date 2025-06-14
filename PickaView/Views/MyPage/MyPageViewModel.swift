//
//  MyPageViewModel.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/15/25.
//

import Foundation
import Combine

class MyPageViewModel {
    private let coreDataManager: CoreDataManager
    
    @Published var weakHistory: [History] = []
    @Published var todayWatchTimeString: String = ""
    @Published var weakWatchTimeString: String = ""
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    func fetchWeakHistory() {
        let histories = coreDataManager.fetchHistory()
        
        self.weakHistory = histories
        
        let today = Calendar.current.startOfDay(for: Date())
        let todayHistory = histories.first { history in
            guard let historyDate = history.date else { return false }
            return Calendar.current.isDate(historyDate, inSameDayAs: today)
        }
        let todaySeconds = todayHistory?.time ?? 0.0
        self.todayWatchTimeString = formatTime(seconds: todaySeconds)
        
        let weakTotalSeconds = histories.reduce(0.0) { $0 + $1.time }
        self.weakWatchTimeString = formatTime(seconds: weakTotalSeconds)
    }
    
    private func formatTime(seconds: Double) -> String {
            guard seconds > 0 else { return "0m" }
            
            let totalSeconds = Int(seconds)
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes)m"
            }
        }
}
