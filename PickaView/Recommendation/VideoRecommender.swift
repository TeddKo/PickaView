//
//  VideoRecommender.swift
//  PickaView
//
//  Created by 장지현 on 6/11/25.
//

import Foundation

enum VideoRecommender {
    /// 주어진 영상 목록에 대해 추천 점수를 계산하고, 이를 기준으로 내림차순 정렬한 결과를 반환
    ///
    /// - Parameter allVideos: 추천 점수를 계산할 'Video' 객체 배열
    /// - Returns: 추천 점수 기준으로 내림차순 정렬된 'Video' 객체 배열
    static func sortVideosByRecommendationScore(from allVideos: [Video]) -> [Video] {
        let scoredVideos = allVideos.map { video in
            let score = RecommendationScorer.calculateRecommendationScore(for: video)
            return (video, score)
        }
        return scoredVideos.sorted { $0.1 > $1.1 }.map { $0.0 }
    }
}
