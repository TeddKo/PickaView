//
//  CoreDataManager.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

import Foundation
import CoreData

/// Core Data의 영속 컨테이너, 컨텍스트 및 기본 데이터 처리 로직을 관리하는 클래스
/// Video 엔티티에 대한 Fetch, Insert, Update, Delete 로직 포함
/// NSFetchedResultsController를 사용하여 자동 UI 갱신과 데이터 동기화 지원
final class CoreDataManager {
    let persistentContainer: NSPersistentContainer
    let mainContext: NSManagedObjectContext
    let fetchedResults: NSFetchedResultsController<Video>

    init() {
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

    /// 전체 Video 엔티티를 fetch하여 배열로 반환
    /// 정렬 기준: id 오름차순 (기본 설정)
    func fetch() -> [Video] {
        fetchedResults.fetchRequest.predicate = nil
        performFetch()
        return fetchedResults.fetchedObjects ?? []
    }

    /// 특정 태그를 포함하는 Video 엔티티만 필터링하여 fetch
    /// - Parameter tag: 검색할 태그 문자열 (대소문자 구분 없이 포함 여부 확인)
    /// - Returns: 해당 태그가 포함된 Video 배열
    func fetch(tag: String) -> [Video] {
        let predicate = NSPredicate(format: "SUBQUERY(tags, $tag, $tag.name CONTAINS[cd] %@).@count > 0", tag)
        fetchedResults.fetchRequest.predicate = predicate
        performFetch()
        return fetchedResults.fetchedObjects ?? []
    }

    /// 추천 점수를 기준으로 정렬된 Video 리스트를 반환
    /// 내부적으로 sortVideosByRecommendationScore 사용
    func fetchRecommended() -> [Video] {
        fetchedResults.fetchRequest.predicate = nil
        performFetch()
        let videos = fetchedResults.fetchedObjects ?? []
        return VideoRecommender.sortVideosByRecommendationScore(from: videos)
    }
    
    /// 좋아요가 눌린 Video만 fetch하여 반환
    func fetchLiked() -> [Video] {
        let predicate = NSPredicate(format: "isLiked == true")
        fetchedResults.fetchRequest.predicate = predicate
        performFetch()
        return fetchedResults.fetchedObjects ?? []
    }

    /// 시청 기록이 있는 Video만 fetch
    /// timeStamp가 존재하고, 그 중 startDate를 기준으로 최신 순 정렬
    func fetchHistory() -> [Video] {
        let predicate = NSPredicate(format: "timeStamp != nil")
        let sortDescriptor = NSSortDescriptor(key: "timeStamp.startDate", ascending: false)
        fetchedResults.fetchRequest.predicate = predicate
        fetchedResults.fetchRequest.sortDescriptors = [sortDescriptor]
        performFetch()
        return fetchedResults.fetchedObjects ?? []
    }

    /// fetchedResultsController를 이용한 fetch 수행
    /// 오류 발생 시 로그 출력
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

    /// 새 비디오 엔티티를 Core Data에 생성하고 속성 세팅
    /// - Parameter video: 저장할 PixabayVideo 데이터
    private func insert(_ video: PixabayVideo) {
        let newVideo = Video(context: mainContext)
        newVideo.id = Int64(video.id)
        apply(video, to: newVideo)
        newVideo.tags = insertTags(from: video.tags)
    }
    
    /// 태그 문자열에서 Tag 객체들을 생성하거나 기존 것을 찾아 NSSet으로 반환
    /// - Parameter tagString: 콤마로 구분된 태그 문자열
    /// - Returns: NSSet 형태의 Tag 집합
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

    /// 기존 Core Data 엔티티에 새 비디오 데이터로 속성 업데이트
    /// - Parameters:
    ///   - entity: 기존 Video 객체
    ///   - video: 새로운 PixabayVideo 데이터
    /// 변경 사항이 없으면 업데이트하지 않음
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
    
    /// 좋아요 상태 변경
    /// - Parameters:
    ///   - video: 대상 Video 객체
    ///   - isLiked: 좋아요 여부 (true/false)
    func updateIsLiked(for video: Video, isLiked: Bool) {
        video.isLiked = isLiked
        
        saveContext()
    }

    /// 영상 시청 시작 시간과 전체 재생 시간을 저장
    /// - Parameters:
    ///   - video: 대상 Video 객체
    ///   - totalTime: 영상 전체 시간
    func updateStartTime(for video: Video, withTotalTime totalTime: Double) {
        if video.timeStamp == nil {
            let stamp = TimeStamp(context: mainContext)
            video.timeStamp = stamp
        }
        video.timeStamp?.startDate = Date()
        video.timeStamp?.totalTime = totalTime
        
        saveContext()
    }

    /// 시청 종료 시간 기록 및 태그 점수 업데이트
    /// - Parameter video: 대상 Video 객체
    /// timeStamp가 없으면 종료 기록 생략
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
    
    /// PixabayVideo의 데이터를 Core Data Video 엔티티에 복사
    /// - Parameters:
    ///   - video: 소스 데이터
    ///   - entity: 대상 Core Data 객체
    private func apply(_ video: PixabayVideo, to entity: Video) {
        entity.url = video.videos.medium.url
        entity.comments = Int64(video.comments)
        entity.user = video.user
        entity.userID = String(video.userID)
        entity.userImageURL = video.userImageURL
        entity.views = Int64(video.views)
    }
    
    /// id를 통해 특정 Video 객체를 직접 삭제
    /// - Parameter id: 삭제할 Video의 고유 ID
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
