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

        let request: NSFetchRequest<Video> = Video.fetchRequest()

        fetchedResults = NSFetchedResultsController(
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
	// fetchedResults를 통해 Core Data에서 데이터를 다시 fetch함
    func fetchAll(keyword: String? = nil) {
        do {
            try fetchedResults.performFetch()
        } catch {
            print("❌ fetch 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - Insert / Update
	// 전달받은 비디오 리스트를 Core Data에 저장
    func saveVideos(_ videos: [PixabayVideo]) {
        for video in videos {
            let videoId = Int64(video.id)

            let request: NSFetchRequest<Video> = Video.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", videoId)

            if let existing = try? mainContext.fetch(request).first {
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
        newVideo.url = video.videos.medium.url
        newVideo.comments = Int64(video.comments)
        newVideo.user = video.user
        newVideo.userID = String(video.userID)
        newVideo.userImageURL = video.userImageURL
        newVideo.views = Int64(video.views)
    }

    // 기존 Core Data 엔티티에 새 비디오 데이터로 속성 업데이트
    func update(entity: Video, with video: PixabayVideo) {
        entity.url = video.videos.medium.url
        entity.comments = Int64(video.comments)
        entity.user = video.user
        entity.userID = String(video.userID)
        entity.userImageURL = video.userImageURL
        entity.views = Int64(video.views)
    }

    // MARK: - Save
 	// mainContext에 변경사항이 있을 때 저장 수행
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
    func updateTagScores(for tags: NSSet?, watchProgress: Double) {
        guard let tags = tags as? Set<Tag> else { return }
        guard watchProgress > 0.3 else { return }

        for tag in tags {
            tag.score += watchProgress
            tag.lastUpdated = Date()
        }

        self.saveContext()
    }
}
