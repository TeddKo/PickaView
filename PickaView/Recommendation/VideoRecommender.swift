//
//  VideoRecommender.swift
//  PickaView
//
//  Created by 장지현 on 6/11/25.
//

import Foundation

enum VideoRecommender {
    /// 전체 영상을 받아 추천 점수를 계산한 후, 점수 기준으로 정렬된 영상 리스트를 반환
    /// - Parameter allVideos: 추천 점수를 계산할 VideoEntity 배열
    /// - Returns: 추천 점수 기준으로 정렬된 VideoEntity 배열
    static func sortVideosByRecommendationScore(from allVideos: [Video]) -> [Video] {
        let scoredVideos = allVideos.map { video in
            let score = RecommendationScorer.calculateRecommendationScore(for: video)
            return (video, score)
        }
        
        return scoredVideos.sorted { $0.1 > $1.1 }.map { $0.0 }
    }
}
