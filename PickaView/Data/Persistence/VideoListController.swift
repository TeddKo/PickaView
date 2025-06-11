//
//  VideoListController.swift
//  PickaView
//
//  Created by DONGNYEONG on 6/10/25.
//

import Foundation
import CoreData

// Core Data VideoEntity를 관리하고 변경 감지를 제공하는 컨트롤러
final class VideoListController: NSObject {
    private(set) var fetchedResultsController: NSFetchedResultsController<VideoEntity>
    // delegate: 변경 이벤트 수신자 (보통 뷰 컨트롤러)
    init(delegate: NSFetchedResultsControllerDelegate?) {
        let fetchRequest: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "views", ascending: false)]

        // NSFetchedResultsController를 사용하여 VideoEntity 객체를 fetch
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()
        fetchedResultsController.delegate = delegate

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ NSFetchedResultsController fetch 실패: \(error.localizedDescription)")
        }
    }

    // 현재 fetch된 VideoEntity 객체 수 반환
    func numberOfItems() -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    // 특정 인덱스 경로에 해당하는 VideoEntity 객체 반환
    func item(at indexPath: IndexPath) -> VideoEntity {
        return fetchedResultsController.object(at: indexPath)
    }
}
