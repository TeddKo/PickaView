//
//  PlayerViewModel.swift
//  PickaView
//
//  Created by 장지현 on 6/13/25.
//

import Foundation

/// 플레이어 화면에서 사용되는 뷰모델
///
/// 비디오 정보, 좋아요 상태, 태그, 추천 영상 목록 등을 제공
/// 영상 시청 시간 기록 및 Core Data 업데이트를 관리
final class PlayerViewModel {
    
    // MARK: - Properties
    
    private let video: Video
    private let coreDataManager: CoreDataManager
    
    /// 사용자가 실제로 영상을 재생한 시간(초)을 누적해서 저장
    /// 1초마다 증가하도록 타이머로 제어
    private var watchedSeconds: TimeInterval = 0
    private var watchTimer: Timer?

    // MARK: - Init
    
    /// 주어진 비디오와 CoreDataManager를 이용하여 뷰모델을 초기화
    ///
    /// - Parameters:
    ///   - video: 현재 재생 중인 비디오 객체
    ///   - coreDataManager: Core Data 작업을 담당하는 매니저
    init(video: Video, coreDataManager: CoreDataManager) {
        self.video = video
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Computed Properties (UI Binding)
    
    var videoURL: String? {
        guard let urlString = video.url else { return nil }
        return urlString
    }

    var thumbnailURL: URL? {
        URL(string: video.thumbnailURL ?? "")
    }
    
    var userImageURL: String {
        video.userImageURL ?? ""
    }

    var user: String {
        video.user ?? "Anonymous"
    }

    var views: String {
        return video.views.formattedViews()
    }

    var isLiked: Bool {
        video.isLiked
    }
    
    var totalTime: Double {
        video.timeStamp?.totalTime ?? 0.0
    }
    
    var tags: [Tag] {
        guard let tagSet = video.tags as? Set<Tag> else { return [] }
        return tagSet.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
    
    var videos: [Video] {
        let allVideos = coreDataManager.fetch()
        let sortedVideos = VideoRecommender.sortVideosByRecommendationScore(from: allVideos)
        let filteredVideos = sortedVideos.filter { $0 != video }
        return Array(filteredVideos.prefix(10))
    }
    
    // MARK: - CoreData Update
    
    func getCoreDataManager() -> CoreDataManager {
        return coreDataManager
    }
    
    func toggleLikeStatus() -> Bool {
        coreDataManager.updateIsLiked(for: video, isLiked: !video.isLiked)
        return video.isLiked
    }
    
    func updateStartTime() {
        let now = Date()
        coreDataManager.updateStartTime(for: video, time: now)
    }
    
    // MARK: - Watch Time Tracking
    
    func startWatching() {
        startTimer()
    }

    func pauseWatching() {
        watchTimer?.invalidate()
        watchTimer = nil
    }

    private func startTimer() {
        watchTimer?.invalidate()
        watchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.watchedSeconds += 1
        }
    }

    func stopAndSaveWatching() {
        watchTimer?.invalidate()
        watchTimer = nil
        coreDataManager.updateTagScores(for: video, watchTime: watchedSeconds)
        coreDataManager.saveHistory(on: Date(), duration: watchedSeconds)
        watchedSeconds = 0
    }
}
