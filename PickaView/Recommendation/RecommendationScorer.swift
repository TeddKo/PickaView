//
//  RecommendationScorer.swift
//  PickaView
//
//  Created by 장지현 on 6/10/25.
//

import Foundation

enum RecommendationScorer {
    /// 주어진 영상에 대해 사용자 선호 태그, 좋아요 여부, 인기 지표를 기반으로 추천 점수를 계산
    ///
    /// - Parameter video: 추천 점수를 계산할 'Video' 객체
    /// - Returns: 0 이상의 추천 점수('Double')
    static func calculateRecommendationScore(for video: Video) -> Double {
        // 각 tag score에 time decay를 곱해 합산
        guard let tags = video.tags as? Set<Tag> else { return 0.0 }
        let userTagValue = tags.reduce(0.0) { $0 + ($1.score * decayWeight(for: $1.lastUpdated)) }
        
        let likeBoost = video.isLiked ? 5.0 : 0.0

        let popularityScore = calculatePopularityScore(
            viewCount: video.views,
            downloadCount: video.downloads,
            commentCount: video.comments
        )
        return userTagValue * 0.6 + likeBoost * 0.1 + popularityScore * 0.3
    }
    
    /// 지정된 날짜를 기준으로 시간에 따라 점수를 지수적으로 감쇠
    ///
    /// - Parameters:
    ///   - date: 감쇠 기준이 되는 날짜
    ///   - baseDays: 감쇠가 적용되는 기준 일수, 기본값 7일
    /// - Returns: 0과 1 사이의 감쇠 가중치('Double')
    static func decayWeight(
        for date: Date?,
        baseDays: Double = 7.0
    ) -> Double {
        guard let date = date else { return 0.0 }
        let daysAgo = Date().timeIntervalSince(date) / (60 * 60 * 24)
        return exp(-daysAgo / baseDays)
    }
    
    /// 조회수, 다운로드 수, 댓글 수를 기반으로 로그 스케일을 적용한 인기 점수를 계산
    ///
    /// - Parameters:
    ///   - viewCount: 영상의 조회 수
    ///   - downloadCount: 영상의 다운로드 수
    ///   - commentCount: 영상의 댓글 수
    /// - Returns: 로그 기반으로 계산된 인기 점수('Double')
    static func calculatePopularityScore(
        viewCount: Int64,
        downloadCount: Int64,
        commentCount: Int64
    ) -> Double {
        let viewScore = log(Double(viewCount) + 1)
        let commentScore = log(Double(commentCount) + 1)
        let downloadScore = log(Double(downloadCount) + 1)
        
        return viewScore * 0.5 + commentScore * 0.3 + downloadScore * 0.2
    }
}
