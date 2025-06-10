//
//  TagScoreCalculator.swift
//  PickaView
//
//  Created by 장지현 on 6/10/25.
//

import Foundation
import CoreData

enum TagScoreCalculator {
    /// Tag Score를 계산합니다.
    /// - Parameters:
    ///   - tags: 추가할 tag들
    ///   - watchProgress: 현재 시청 중인 영상 시간 / 전체 영상 시간
    static func calculateUserTagScores(for tags: Set<TagEntity>, watchProgress: Double) {
        guard watchProgress > 0.3 else { return }

        for tag in tags {
            tag.score += watchProgress
            tag.lastUpdated = Date()
        }
        
        CoreDataManager.shared.saveContext()
    }
}
