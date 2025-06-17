//
//  LikeViewModel.swift
//  PickaView
//
//  Created by junil on 6/13/25.
//

import Foundation
import Combine
import CoreData

/// '좋아요' 탭의 비즈니스 로직과 데이터를 관리하는 뷰모델.
///
/// CoreData에서 '좋아요'한 비디오를 가져오고, 페이징 처리 및 FRC를 통해 데이터 변경을 감지하여 UI를 업데이트함.
final class LikeViewModel: NSObject, ObservableObject {
    
    /// 페이징 처리를 위한 현재 페이지 번호.
    private(set) var currentPage: Int = 1
    /// 페이지 당 표시할 아이템의 수.
    private let limit: Int = 20
    /// 더 로드할 페이지가 있는지 여부.
    private var hasMore = true
    
    /// CoreData 영속성 컨테이너를 관리하는 객체.
    private let coreDataManager: CoreDataManager
    /// 데이터 작업을 수행하는 메인 스레드의 Managed Object Context.
    private let context: NSManagedObjectContext

    /// '좋아요'한 비디오 목록을 효율적으로 가져오고 변경사항을 감지하는 Fetched Results Controller.
    var frc: NSFetchedResultsController<Video>!

    /// LikeViewModel의 새 인스턴스를 초기화함.
    ///
    /// - Parameter coreDataManager: 의존성으로 주입되는 CoreDataManager 인스턴스.
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        self.context = coreDataManager.persistentContainer.viewContext
        super.init()
        setupFRC()
    }

    /// '좋아요'한 비디오를 가져오기 위한 FRC(Fetched Results Controller)를 설정함.
    ///
    /// `isLiked`가 true인 비디오를 대상으로, 가장 최근에 본 순서대로 정렬하여 가져옴.
    private func setupFRC() {
        let predicate = NSPredicate(format: "isLiked == true")
        self.frc = FRCFactory.makeVideoFRC(
            context: context,
            predicate: predicate,
            sortDescriptors: [NSSortDescriptor(key: "timeStamp.startDate", ascending: false)],
            delegate: nil
        )
        
        do {
            try self.frc.performFetch()
        } catch {
            print("Failed to fetch videos: \(error)")
        }
    }

    /// FRC를 새로고침하여 CoreData로부터 최신 데이터를 다시 가져옴.
    ///
    /// 현재 페이지를 1로 초기화함.
    func refreshFRC() {
        do {
            try frc.performFetch()
            currentPage = 1
        } catch {
            print("Failed to refetch videos: \(error)")
        }
    }

    /// 지정된 비디오의 '좋아요' 상태를 토글(변경)함.
    ///
    /// - Parameter video: '좋아요' 상태를 변경할 Video 객체.
    func toggleLike(for video: Video) {
        coreDataManager.updateIsLiked(for: video, isLiked: !video.isLiked)
    }

    /// 이 뷰모델이 사용 중인 CoreDataManager 인스턴스를 반환함.
    ///
    /// - Returns: 현재 사용 중인 CoreDataManager 인스턴스.
    func getCoreDataManager() -> CoreDataManager {
        return coreDataManager
    }
    
    /// FRC에서 가져온 전체 비디오 목록 중 현재 페이지에 해당하는 부분을 잘라 반환함.
    ///
    /// - Returns: 현재 페이지에 해당하는 Video 객체 배열.
    func getCurrentPageVideos() -> [Video] {
        guard let videos = frc.fetchedObjects else { return [] }
        let offset = (currentPage - 1) * limit
        let end = min(offset + limit, videos.count)
        guard offset < end else { return [] }
        return Array(videos[offset..<end])
    }
    
    /// 다음 페이지를 로드하고 해당 페이지의 비디오 목록을 반환함.
    ///
    /// - Returns: 다음 페이지에 해당하는 Video 객체 배열.
    func loadNextPage() -> [Video] {
        currentPage += 1
        return getCurrentPageVideos()
    }
}
