//
//  PlayerViewModel.swift
//  PickaView
//
//  Created by 장지현 on 6/13/25.
//

import Foundation

final class PlayerViewModel {
    private let video: Video
    
    init(video: Video) {
        self.video = video
    }
    
    var videoURL: URL? {
        URL(string: video.url ?? "")
    }

    var thumbnailURL: URL? {
        URL(string: video.thumbnailURL ?? "")
    }
    
    var userImageURL: URL? {
        URL(string: video.thumbnailURL ?? "")
    }

    var user: String {
        video.user ?? ""
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
}
