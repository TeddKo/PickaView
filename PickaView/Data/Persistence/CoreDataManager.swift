//
//  CoreDataManager.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

import Foundation
import CoreData

final class CoreDataManager {
    let persistentContainer: NSPersistentContainer
    let mainContext: NSManagedObjectContext
    let fetchedResults: NSFetchedResultsController<Video>

    init() {
        // Core Data 스택 초기화
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Core Data 스토어 로드 실패: \(error), \(error.userInfo)")
            }
        }
        persistentContainer = container
        mainContext = container.viewContext

        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        fetchedResults = NSFetchedResultsController(
            fetchRequest: fetchRequest,
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

    func fetch() {
        fetchedResults.fetchRequest.predicate = nil
        performFetch()
    }

    func fetch(tag: String) {
        let predicate = NSPredicate(format: "SUBQUERY(tags, $tag, $tag.name CONTAINS[cd] %@).@count > 0", tag)
        fetchedResults.fetchRequest.predicate = predicate
        performFetch()
    }

    func fetchRecommended() -> [Video] {
        performFetch()
        let videos = fetchedResults.fetchedObjects ?? []
        return VideoRecommender.sortVideosByRecommendationScore(from: videos)
    }

    private func performFetch() {
        do {
            try fetchedResults.performFetch()
        } catch {
            print("❌ fetch 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - Insert / Update
    // 전달받은 비디오 리스트를 Core Data에 저장
    func saveVideos(_ videos: [PixabayVideo]) {
        if fetchedResults.fetchedObjects == nil || fetchedResults.fetchedObjects?.isEmpty == true {
            fetch()
        }
        
        let existingVideos = fetchedResults.fetchedObjects ?? []
        let existingVideoDict = Dictionary(uniqueKeysWithValues: existingVideos.map { ($0.id, $0) })

        let incomingIDs = Set(videos.map { Int64($0.id) })
        let idsToDelete = Set(existingVideoDict.keys).subtracting(incomingIDs)
        for id in idsToDelete {
            delete(by: id)
        }
        
        for video in videos {
            let videoId = Int64(video.id)
            
            if let existing = existingVideoDict[videoId] {
                update(entity: existing, with: video)
            } else {
                insert(video)
            }
        }
        
        saveContext()
    }

    // 새 비디오 엔티티를 Core Data에 생성하고 속성 세팅
    private func insert(_ video: PixabayVideo) {
        let newVideo = Video(context: mainContext)
        newVideo.id = Int64(video.id)
        apply(video, to: newVideo)
        newVideo.tags = insertTags(from: video.tags)
    }
    
    // 태그 문자열에서 Tag 객체들을 생성하거나 기존 것을 찾아 NSSet으로 반환
    private func insertTags(from tagString: String) -> NSSet {
        let tagNames = tagString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        let tagSet: Set<Tag> = Set(tagNames.compactMap { name in
            let request: NSFetchRequest<Tag> = Tag.fetchRequest()
            request.predicate = NSPredicate(format: "name =[c] %@", name)
            request.fetchLimit = 1

            if let existing = try? mainContext.fetch(request).first {
                return existing
            } else {
                let tag = Tag(context: mainContext)
                tag.name = name
                return tag
            }
        })

        return tagSet as NSSet
    }

    // 기존 Core Data 엔티티에 새 비디오 데이터로 속성 업데이트
    func update(entity: Video, with video: PixabayVideo) {
        guard entity.url != video.videos.medium.url ||
              entity.comments != video.comments ||
              entity.user != video.user ||
              entity.userID != String(video.userID) ||
              entity.userImageURL != video.userImageURL ||
              entity.views != video.views
        else {
            return
        }
        
        apply(video, to: entity)
    }
    
    func updateIsLiked(for video: Video, isLiked: Bool) {
        video.isLiked = isLiked
        
        saveContext()
    }

    func updateStartTime(for video: Video, withTotalTime totalTime: Double) {
        if video.timeStamp == nil {
            let stamp = TimeStamp(context: mainContext)
            video.timeStamp = stamp
        }
        video.timeStamp?.startDate = Date()
        video.timeStamp?.totalTime = totalTime
        
        saveContext()
    }

    func updateEndTime(for video: Video) {
        guard let timeStamp = video.timeStamp else {
            print("❌ timeStamp가 존재하지 않아 endDate를 기록할 수 없음")
            return
        }
        timeStamp.endDate = Date()
        updateTagScores(for: video)
        
        saveContext()
    }
    
    /// Tag Score 계산
    /// - Parameters:
    ///   - video: Tag 점수를 업데이트할 Video 객체
    func updateTagScores(for video: Video) {
        guard let tags = video.tags as? Set<Tag> else { return }
        guard let timeStamp = video.timeStamp,
              let startDate = timeStamp.startDate,
              let endDate = timeStamp.endDate else { return }

        let interval = endDate.timeIntervalSince(startDate)
        guard timeStamp.totalTime > 0 else { return }

        let rawProgress = interval / timeStamp.totalTime
        let roundedProgress = (rawProgress * 100).rounded() / 100

        guard roundedProgress > 0.3 else { return }

        for tag in tags {
            tag.score += roundedProgress
            tag.lastUpdated = Date()
        }

        saveContext()
    }
    
    private func apply(_ video: PixabayVideo, to entity: Video) {
        entity.url = video.videos.medium.url
        entity.comments = Int64(video.comments)
        entity.user = video.user
        entity.userID = String(video.userID)
        entity.userImageURL = video.userImageURL
        entity.views = Int64(video.views)
    }
    
    // MARK: - Delete

    // id를 통해 특정 Video 객체를 직접 삭제
    func delete(by id: Int64) {
        guard let toDelete = fetchedResults.fetchedObjects?.first(where: { $0.id == id }) else { return }
        mainContext.delete(toDelete)
    }

    // MARK: - Save
     // mainContext에 변경사항이 있을 때 저장 수행
    @discardableResult
    func saveContext() -> Bool {
        guard mainContext.hasChanges else { return true }

        do {
            try mainContext.save()
            print("✅ 저장 성공")
            return true
        } catch {
            print("❌ 저장 실패: \(error.localizedDescription)")
            return false
        }
    }
}
