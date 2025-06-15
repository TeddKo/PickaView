
//
//  LikeViewModel.swift
//  PickaView
//
//  Created by junil on 6/13/25.
//

import Foundation

/// 셀 구성에 필요한 데이터를 담는 뷰 전용 구조체
struct LikeCellViewData {
    let videoURL: String
    let date: Date
    let thumbnailURL: String
    let videoLength: Int
    let tags: [String]
    let likeCount: Int
}

/**
 CoreData로부터 좋아요한 비디오를 가져오고 처리하는 뷰모델
 */
final class LikeViewModel {

    /// CoreData 액세스를 위한 매니저
    let coreDataManager: CoreDataManager

    /// 좋아요한 비디오 목록
    private(set) var likedVideos: [Video] = []

    // MARK: - 초기화

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        fetchLikedVideos()
    }

    // MARK: - 데이터 갱신

    /// CoreData에서 좋아요한 비디오를 불러와 `likedVideos`에 저장
    func fetchLikedVideos() {
        let all = coreDataManager.fetch()
        likedVideos = all.filter { $0.isLiked }
        print("❤️ 좋아요 비디오 개수: \(likedVideos.count)")
    }

    // MARK: - 조회

    /// 좋아요한 비디오 개수
    var likeCount: Int {
        likedVideos.count
    }

    /// 셀에 필요한 데이터를 반환
    func cellData(at index: Int) -> LikeCellViewData? {
        guard likedVideos.indices.contains(index) else { return nil }
        let video = likedVideos[index]
        return LikeCellViewData(
            videoURL: video.url ?? "",
            date: video.timeStamp?.startDate ?? .now,
            thumbnailURL: video.thumbnailURL ?? "",
            videoLength: Int(video.timeStamp?.totalTime ?? 0),
            tags: (video.tags as? Set<Tag>)?.compactMap { $0.name } ?? [],
            likeCount: 1
        )
    }

    /// 좋아요한 비디오 중 인덱스에 해당하는 Video 객체 반환
    func video(at index: Int) -> Video? {
        guard likedVideos.indices.contains(index) else { return nil }
        return likedVideos[index]
    }

    // MARK: - 좋아요 토글

    /// 해당 인덱스의 좋아요 상태를 반전시키고, 목록을 다시 불러옴
    func toggleLike(at index: Int) {
        guard let video = video(at: index) else { return }
        coreDataManager.updateIsLiked(for: video, isLiked: !video.isLiked)
        fetchLikedVideos()
    }
}
