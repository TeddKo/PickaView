//
//  PlayerViewModel.swift
//  PickaView
//
//  Created by 장지현 on 6/13/25.
//

import Foundation

final class PlayerViewModel {
    
    // MARK: - Properties
    
    private let video: Video
    private let coreDataManager: CoreDataManager
    
    /// 사용자가 실제로 영상을 재생한 시간(초)을 누적해서 저장
    /// 1초마다 증가하도록 타이머로 제어
    private var watchedSeconds: TimeInterval = 0
    private var watchTimer: Timer?

    // MARK: - Init
    
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
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedViews = numberFormatter.string(from: NSNumber(value: video.views)) ?? "\(video.views)"
        return "\(formattedViews) views"
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
