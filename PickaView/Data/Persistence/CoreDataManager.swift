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
final class CoreDataManager {
    let persistentContainer: NSPersistentContainer
    let mainContext: NSManagedObjectContext

    init() {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Core Data 스토어 로드 실패: \(error), \(error.userInfo)")
            }
        }
        persistentContainer = container
        mainContext = container.viewContext
    }

    // MARK: - Fetch

    /// 전체 Video 엔티티를 fetch하여 배열로 반환
    /// 정렬 기준: id 오름차순 (기본 설정)
    func fetch() -> [Video] {
        let request: NSFetchRequest<Video> = Video.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        do {
            return try mainContext.fetch(request)
        } catch {
            print("❌ fetch 실패: \(error.localizedDescription)")
            return []
        }
    }

    /// 특정 태그를 포함하는 Video 엔티티만 필터링하여 fetch
    /// - Parameter tag: 검색할 태그 문자열 (대소문자 구분 없이 포함 여부 확인)
    /// - Returns: 해당 태그가 포함된 Video 배열
    func fetch(tag: String) -> [Video] {
        let request: NSFetchRequest<Video> = Video.fetchRequest()
        request.predicate = NSPredicate(format: "SUBQUERY(tags, $tag, $tag.name CONTAINS[cd] %@).@count > 0", tag)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        do {
            return try mainContext.fetch(request)
        } catch {
            print("❌ tag 기반 fetch 실패: \(error.localizedDescription)")
            return []
        }
    }

    /// 모든 Tag 엔티티를 이름 순으로 정렬하여 fetch
    /// - Returns: 이름 오름차순으로 정렬된 Tag 배열
    func fetchAllTags() async -> [Tag] {
        return await withCheckedContinuation { continuation in
            mainContext.perform {
                let request: NSFetchRequest<Tag> = Tag.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
                do {
                    let tags = try self.mainContext.fetch(request)
                    continuation.resume(returning: tags)
                } catch {
                    print("❌ 태그 fetch 실패: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                }
            }
        }
    }

    // MARK: - Save
    
    /// 전달받은 비디오 리스트를 Core Data에 저장
    /// - Parameter videos: 네트워크 요청으로 받은 Video
    func saveVideos(_ videos: [PixabayVideo]) {
        let existingVideos: [Video] = fetch()
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
        
        deleteTags()
        
        saveContext()
    }

    /// 날짜 기반 시청 기록을 History 엔티티에 저장
    /// - Parameters:
    ///   - date: 시청이 발생한 시간 (Date)
    ///   - duration: 시청 시간 (초 단위)
    func saveHistory(on date: Date, duration: Double) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        guard let dayStart = calendar.date(from: components) else { return }

        let request: NSFetchRequest<History> = History.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", dayStart as NSDate)
        request.fetchLimit = 1

        do {
            if let existing = try mainContext.fetch(request).first {
                existing.time += duration
            } else {
                let newHistory = History(context: mainContext)
                newHistory.date = dayStart
                newHistory.time = duration
            }

            saveContext()
        } catch {
            print("❌ 히스토리 저장 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Insert / Update
    
    /// 새 비디오 엔티티를 Core Data에 생성하고 속성 세팅
    /// - Parameter video: 저장할 PixabayVideo 데이터
    private func insert(_ video: PixabayVideo) {
        let newVideo = Video(context: mainContext)
        let newStamp = TimeStamp(context: mainContext)
        newVideo.id = Int64(video.id)
        newVideo.isLiked = false
        newVideo.tags = insertTags(from: video.tags)
        newVideo.timeStamp = newStamp
        apply(video, to: newVideo)
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

    /// 기존 Core Data 엔티티에 새 비디오 데이터로 속성 업데이트, 변경 사항이 없으면 업데이트하지 않음
    /// - Parameters:
    ///   - entity: 기존 Video 객체
    ///   - video: 새로운 PixabayVideo 데이터
    func update(entity: Video, with video: PixabayVideo) {
        guard entity.url != video.videos.medium.url ||
              entity.thumbnailURL != video.videos.medium.thumbnail ||
              entity.views != Int64(video.views) ||
              entity.comments != Int64(video.comments) ||
              entity.downloads != Int64(video.downloads) ||
              entity.user != video.user ||
              entity.userID != String(video.userID) ||
              entity.userImageURL != video.userImageURL ||
              entity.timeStamp?.totalTime != Double(video.duration)
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
        guard video.isLiked != isLiked else { return }
        
        video.isLiked = isLiked
        
        let scoreChange = isLiked ? 1.0 : -1.0
        
        if let tags = video.tags as? Set<Tag> {
            for tag in tags {
                tag.score += scoreChange
                if tag.score < 0 {
                    tag.score = 0
                }
            }
        }
        saveContext()
    }

    /// 영상 시청 시작 시간을 저장
    /// - Parameters:
    ///   - video: 대상 Video 객체
    ///   - totalTime: 영상 전체 시간
    func updateStartTime(for video: Video, time: Date) {
        if video.timeStamp == nil {
            let stamp = TimeStamp(context: mainContext)
            video.timeStamp = stamp
        }
        video.timeStamp?.startDate = time
        
        saveContext()
    }
    
    /// Tag Score 계산
    /// - Parameters:
    ///   - video: Tag 점수를 업데이트할 Video 객체
    func updateTagScores(for video: Video, watchTime: TimeInterval) {
        guard let tags = video.tags as? Set<Tag> else { return }
        guard let timeStamp = video.timeStamp, timeStamp.totalTime > 0 else { return }

        let rawProgress = watchTime / timeStamp.totalTime
        let roundedProgress = (rawProgress * 100).rounded() / 100

        guard roundedProgress > 0.15 else { return }

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
        entity.thumbnailURL = video.videos.medium.thumbnail
        entity.views = Int64(video.views)
        entity.comments = Int64(video.comments)
        entity.downloads = Int64(video.downloads)
        entity.user = video.user
        entity.userID = String(video.userID)
        entity.userImageURL = video.userImageURL
        entity.timeStamp?.totalTime = Double(video.duration)
    }
    
    // MARK: - Delete
    
    /// id를 통해 특정 Video 객체를 직접 삭제
    /// - Parameter id: 삭제할 Video의 고유 ID
    func delete(by id: Int64) {
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        fetchRequest.fetchLimit = 1
        do {
            if let toDelete = try mainContext.fetch(fetchRequest).first {
                mainContext.delete(toDelete)
            }
        } catch {
            print("❌ 삭제할 비디오 fetch 실패: \(error.localizedDescription)")
        }
    }
    
    /// Video가 없는 Tag 삭제
    func deleteTags() {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        do {
            let tags = try mainContext.fetch(request)
            for tag in tags {
                if let videos = tag.videos, videos.count == 0 {
                    mainContext.delete(tag)
                }
            }
            
            saveContext()
        } catch {
            print("❌ 태그 삭제 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - SaveContext
    
    /// mainContext에 변경사항이 있을 때 저장 수행
    @discardableResult
    func saveContext() -> Bool {
        guard mainContext.hasChanges else { return true }

        do {
            try mainContext.save()
            return true
        } catch {
            print("❌ 저장 실패: \(error.localizedDescription)")
            return false
        }
    }
}
