//
//  RecommendationScorer.swift
//  PickaView
//
//  Created by 장지현 on 6/10/25.
//

import Foundation

enum RecommendationScorer {
    /// 영상 객체를 입력 받아, 태그 선호 점수, 좋아요 여부, 인기 점수를 종합하여 추천 점수 계산
    /// - Parameters:
    ///   - video: 추천 점수를 계산할 대상 VideoEntity
    /// - Returns: 0이상 Double 값의 추천 점수
    static func calculateRecommendationScore(for video: VideoEntity) -> Double {
        // 각 tag score에 time decay를 곱해 합산
        guard let tags = video.tags else { return 0.0 }
        let userTagValue = tags.reduce(0.0) { $0 + ($1.score * decayWeight(for: $1.lastUpdated)) }
        
        let likeBoost = video.isLiked ? 5.0 : 0.0

        let popularityScore = calculatePopularityScore(viewCount: video.views, downloadCount: video.downloads, commentCount: video.comments)

        return userTagValue * 0.5 + likeBoost * 0.2 + popularityScore * 0.3
    }
    
    /// 지정된 날짜(기본값 7일)를 기준으로 점수가 지수적으로 감소
    /// - Parameters:
    ///   - date: 기준 날짜
    ///   - baseDays: 감쇠 기준일
    /// - Returns: 0 과 1 사이의 감쇠 가중치 계수
    static func decayWeight(for date: Date?, baseDays: Double = 7.0) -> Double {
        guard let date = date else { return 0.0 }
        let daysAgo = Date().timeIntervalSince(date) / (60 * 60 * 24)
        return exp(-daysAgo / baseDays)
    }
    
    /// 영상의 조회수, 다운로드 수, 댓글 수를 기반으로 로그 스케일을 적용한 인기 점수 계산
    /// - Parameters:
    ///   - viewCount: 조회수
    ///   - downloadCount: 다운로드 수
    ///   - commentCount: 댓글 수
    /// - Returns: 로그 기반의 가중 합산 점수
    static func calculatePopularityScore(viewCount: Int64, downloadCount: Int64, commentCount: Int64) -> Double {
        let viewScore = log(Double(viewCount) + 1)
        let commentScore = log(Double(commentCount) + 1)
        let downloadScore = log(Double(downloadCount) + 1)
        
        return viewScore * 0.5 + commentScore * 0.3 + downloadScore * 0.2
    }
}
