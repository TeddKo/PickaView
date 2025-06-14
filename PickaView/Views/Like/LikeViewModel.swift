//
//  LikeViewModel.swift
//  PickaView
//
//  Created by junil on 6/13/25.
//

import Foundation

struct LikeCellViewData {
    let date: Date
    let thumbnailURL: String
    let videoLength: Int
    let tags: [String]
    let likeCount: Int

    init(date: Date, thumbnailURL: String, videoLength: Int, tags: [String], likeCount: Int) {
        self.date = date
        self.thumbnailURL = thumbnailURL
        self.videoLength = videoLength
        self.tags = tags
        self.likeCount = likeCount
    }
}

final class LikeViewModel {
    private let coreDataManager: CoreDataManager

    private(set) var likedVideos: [Video] = []

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        fetchLikedVideos()
    }

    func fetchLikedVideos() {
        let all = coreDataManager.fetch()
        likedVideos = all.filter { $0.isLiked }
    }

    var likeCount: Int {
        likedVideos.count
    }

    func cellData(at index: Int) -> LikeCellViewData? {
        guard likedVideos.indices.contains(index) else { return nil }
        let video = likedVideos[index]
        return LikeCellViewData(
            date: video.timeStamp?.startDate ?? .now,
            thumbnailURL: video.thumbnailURL ?? "",
            videoLength: Int(video.timeStamp?.totalTime ?? 0),
            tags: (video.tags as? Set<Tag>)?.compactMap { $0.name } ?? [],
            likeCount: 1 // 본인만 누른 경우 1, (여러 명일 경우 별도 필드에서 꺼내세요)
        )
    }

    func video(at index: Int) -> Video? {
        guard likedVideos.indices.contains(index) else { return nil }
        return likedVideos[index]
    }

    func toggleLike(at index: Int) {
        guard let video = video(at: index) else { return }
        coreDataManager.updateIsLiked(for: video, isLiked: !video.isLiked)
        fetchLikedVideos()
    }
}
