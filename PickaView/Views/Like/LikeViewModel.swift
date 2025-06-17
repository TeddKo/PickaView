//
//  LikeViewModel.swift
//  PickaView
//
//  Created by junil on 6/13/25.
//

import Foundation
import Combine
import CoreData

final class LikeViewModel: NSObject, ObservableObject {
    private let coreDataManager: CoreDataManager
    private let context: NSManagedObjectContext

    var frc: NSFetchedResultsController<Video>!

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
        // delegate는 ViewController에서 설정할 것이므로 nil로 초기화합니다.
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

    // MARK: - 좋아요 토글
    func toggleLike(for video: Video) {
            coreDataManager.updateIsLiked(for: video, isLiked: !video.isLiked)
        }
    
    func getCoreDataManager() -> CoreDataManager {
        return coreDataManager
    }
}
