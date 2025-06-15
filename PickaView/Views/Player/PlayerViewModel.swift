//
//  PlayerViewModel.swift
//  PickaView
//
//  Created by 장지현 on 6/13/25.
//

import Foundation

final class PlayerViewModel {
    private let video: Video
    private let coreDataManager: CoreDataManager

    init(video: Video, coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        self.video = video
    }
    
    var videoURL: URL? {
        URL(string: video.url ?? "")
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
    
    func getCoreDataManager() -> CoreDataManager {
        return coreDataManager
    }
    
    func toggleLikeStatus() -> Bool {
        coreDataManager.updateIsLiked(for: video, isLiked: !video.isLiked)
        return video.isLiked
    }
}
