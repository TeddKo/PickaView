//
//  HomeViewModel.swift
//  PickaView
//
//  Created by 장지현 on 6/13/25.
//
import Foundation

final class HomeViewModel {
    private let coreDataManager: CoreDataManager
    private let pixabayVideoService: PixabayVideoService
    private var allRecommendedVideos: [Video] = []
    private(set) var currentPage: Int = 1
    private let limit: Int = 20
    private var hasMore = true
    private(set) var allTags: [Tag] = []

    init(coreDataManager: CoreDataManager, pixabayVideoService: PixabayVideoService) {
        self.coreDataManager = coreDataManager
        self.pixabayVideoService = pixabayVideoService
    }

    /// 네트워크에서 비디오를 가져오고 Core Data에 저장
    func fetchAndSaveVideos(query: String? = nil) async {
        do {
            // 네트워크에서 비디오 데이터 가져오기
            let videos = try await pixabayVideoService.fetchVideos(query: query)
            await MainActor.run {
                // Core Data에 비디오 데이터 저장
                print("Saving videos to Core Data")
                self.coreDataManager.saveVideos(videos)
                print("Saved videos successfully")
            }
        } catch {
            // 네트워크 요청 실패 시 에러 출력
            print("Failed to fetch videos: \(error.localizedDescription)")
        }

    }
    
    func refreshVideos() {
        let allVideos = coreDataManager.fetch()
        self.allRecommendedVideos = VideoRecommender.sortVideosByRecommendationScore(from: allVideos)
        self.currentPage = 1
    }

    func getCurrentPageVideos() -> [Video] {
        let offset = (currentPage - 1) * limit
        let end = min(offset + limit, allRecommendedVideos.count)
        guard offset < end else { return [] }
        return Array(allRecommendedVideos[offset..<end])
    }

    func loadNextPage() -> [Video] {
        currentPage += 1
        return getCurrentPageVideos()
    }

    /// CoreDataManager를 통해 모든 태그를 비동기적으로 가져옴
    /// 메인 스레드에서 `allTags` 프로퍼티에 저장
    func loadAllTags() async {
        let tags = await coreDataManager.fetchAllTags()
        await MainActor.run {
            self.allTags = tags
        }
    }
    
     //실시간 태그목록 갱신용
    func filterTags(keyword: String) -> [Tag] {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return allTags // 아무 키워드도 없으면 전체 태그 반환
        }

        let lowercasedKeyword = trimmed.lowercased()

        return allTags.filter { tag in
            guard let name = tag.name?.lowercased() else { return false }
            return name.hasPrefix(lowercasedKeyword)
        }
    }

    func fetchVideosForTag(_ tagName: String) -> [Video] {
        return coreDataManager.fetch(tag: tagName)
    }
}
