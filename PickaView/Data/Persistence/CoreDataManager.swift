//
//  CoreDataManager.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    let mainContext: NSManagedObjectContext
    let fetchedResults: NSFetchedResultsController<VideoEntity>
    
    private init() {
        // Core Data 스택 초기화
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Core Data 스토어 로드 실패: \(error), \(error.userInfo)")
            }
        }
        self.persistentContainer = container
        self.mainContext = container.viewContext
        
        // FetchRequest 및 정렬 기준 설정
        let request: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()
        let sortByIDDesc = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sortByIDDesc]
        
        self.fetchedResults = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResults.performFetch()
        } catch {
            print("❌ 초기 fetch 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch
    
    func fetchAll(keyword: String? = nil) {
        if let keyword {
            let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(VideoEntity.user), keyword)
            fetchedResults.fetchRequest.predicate = predicate
        } else {
            fetchedResults.fetchRequest.predicate = nil
        }
        
        do {
            try fetchedResults.performFetch()
        } catch {
            print("❌ fetch 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Insert / Update
    
    func saveVideos(_ videos: [PixabayVideo]) {
        for video in videos {
            let videoId = Int64(video.id)
            
            let request: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", videoId)
            
            if let existing = try? mainContext.fetch(request).first {
                update(entity: existing, with: video)
            } else {
                insert(video)
            }
        }
        saveContext()
    }
    
    private func insert(_ video: PixabayVideo) {
        let newVideo = VideoEntity(context: mainContext)
        newVideo.id = Int64(video.id)
        newVideo.url = video.videos.medium.url
        newVideo.comments = Int64(video.comments)
        newVideo.user = video.user
        newVideo.userID = String(video.userID)
        newVideo.userImageURL = video.userImageURL
        newVideo.views = Int64(video.views)
    }
    
    func update(entity: VideoEntity, with video: PixabayVideo) {
        entity.url = video.videos.medium.url
        entity.comments = Int64(video.comments)
        entity.user = video.user
        entity.userID = String(video.userID)
        entity.userImageURL = video.userImageURL
        entity.views = Int64(video.views)
    }
    
    // MARK: - Delete
    
    // 특정 VideoEntity 객체를 직접 삭제
    func delete(entity: VideoEntity) {
        mainContext.delete(entity)
        saveContext()
    }
    
    // 특정 테이블/컬렉션 뷰에서 indexPath를 통해 삭제
    func delete(at indexPath: IndexPath) {
        let target = fetchedResults.object(at: indexPath)
        delete(entity: target)
    }
    
    // MARK: - Save
    
    func saveContext() {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
                print("✅ Core Data 저장 성공")
            } catch {
                print("❌ Core Data 저장 실패: \(error.localizedDescription)")
            }
        }
    }
    
    /// Tag Score를 계산합니다.
    /// - Parameters:
    ///   - tags: 추가할 tag들
    ///   - watchProgress: 현재 시청 중인 영상 시간 / 전체 영상 시간
    func calculateUserTagScores(for tags: Set<TagEntity>, watchProgress: Double) {
        guard watchProgress > 0.3 else { return }
        
        for tag in tags {
            tag.score += watchProgress
            tag.lastUpdated = Date()
        }
        
        CoreDataManager.shared.saveContext()
    }
}
