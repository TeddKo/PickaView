//
//  LikeViewModel.swift
//  PickaView
//
//  Created by junil on 6/13/25.
//

import Foundation
import Combine
import CoreData

/// 변경된 셀들의 indexPath 목록을 담는 구조체
/// UICollectionView에서 performBatchUpdates를 통해 insert/delete/move 처리에 사용됨
struct FRCChangeSet {
    var insertions: [IndexPath] = []
    var deletions: [IndexPath] = []
    var updates: [IndexPath] = []
    var moves: [(from: IndexPath, to: IndexPath)] = []

    var isEmpty: Bool {
        return insertions.isEmpty && deletions.isEmpty && updates.isEmpty && moves.isEmpty
    }
}

/// 셀 구성에 필요한 데이터를 담는 뷰 전용 구조체
struct LikeCellViewData {
    let videoURL: String
    let date: Date
    let thumbnailURL: String
    let videoLength: Int
    let tags: [String]
    let likeCount: Int
}

/// MVVM의 ViewModel 역할. CoreData에서 좋아요된 Video를 관리하고, FRC로 변경사항 감지함
final class LikeViewModel: NSObject, ObservableObject {
    private let coreDataManager: CoreDataManager
    private let context: NSManagedObjectContext

    private var frc: NSFetchedResultsController<Video>!
    private var pendingChangeSet = FRCChangeSet()

    /// 변경된 셀 정보가 담긴 퍼블리셔. ViewController에서 이걸 구독하여 셀 업데이트 처리
    let changesPublisher = PassthroughSubject<FRCChangeSet, Never>()

    /// 좋아요된 비디오 목록. @Published로 UI 갱신 트리거
    @Published var likedVideos: [Video] = []

    // MARK: - Init

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        self.context = coreDataManager.persistentContainer.viewContext
        super.init()
        setupFRC()
    }

    // MARK: - FRC 세팅

    private func setupFRC() {
        let predicate = NSPredicate(format: "isLiked == true")
        self.frc = FRCFactory.makeVideoFRC(
            context: context,
            predicate: predicate,
            sortDescriptors: [NSSortDescriptor(key: "timeStamp.startDate", ascending: false)],
            delegate: self
        )
        self.likedVideos = frc.fetchedObjects ?? []
    }

    // MARK: - 셀 데이터 추출

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

    func video(at index: Int) -> Video? {
        guard likedVideos.indices.contains(index) else { return nil }
        return likedVideos[index]
    }

    var likeCount: Int {
        likedVideos.count
    }

    // MARK: - 좋아요 토글

    func toggleLike(at index: Int) {
        guard let video = video(at: index) else { return }
        coreDataManager.updateIsLiked(for: video, isLiked: !video.isLiked)
    }

    // MARK: - 테스트용 더미 좋아요 주입

    func injectTestLikesIfNeeded() {
        let allVideos = coreDataManager.fetch()
        for video in allVideos.prefix(5) {
            coreDataManager.updateIsLiked(for: video, isLiked: true)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate 구현 (셀 변경 감지)
extension LikeViewModel: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pendingChangeSet = FRCChangeSet()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                pendingChangeSet.insertions.append(newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                pendingChangeSet.deletions.append(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                pendingChangeSet.updates.append(indexPath)
            }
        case .move:
            if let from = indexPath, let to = newIndexPath {
                pendingChangeSet.moves.append((from: from, to: to))
            }
        default: break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        likedVideos = frc.fetchedObjects ?? []
        if !pendingChangeSet.isEmpty {
            changesPublisher.send(pendingChangeSet)
        }
    }
}
