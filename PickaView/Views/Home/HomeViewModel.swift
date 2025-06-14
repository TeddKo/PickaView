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
    private var page = 1            // currentPage → page
 	private let perPage = 20        // default 페이지 수
    private var isFetching = false
    private var hasMore = true      // hasMoreData → hasMore
    private(set) var allTags: [Tag] = []

    init(coreDataManager: CoreDataManager, pixabayVideoService: PixabayVideoService) {
        self.coreDataManager = coreDataManager
        self.pixabayVideoService = pixabayVideoService
    }

    /// 네트워크에서 비디오를 가져오고 Core Data에 저장
    func fetchAndSaveVideos(query: String? = nil) async {
        guard !isFetching, hasMore else { return }
        isFetching = true

        do {
            // 네트워크에서 비디오 데이터 가져오기 (페이지 단위)
            let videos = try await pixabayVideoService.fetchVideos(query: query, page: page, perPage: perPage)
            if videos.isEmpty {
                hasMore = false
            } else {
                await MainActor.run {
                    // Core Data에 비디오 데이터 저장
                    print("Saving videos to Core Data")
                    self.coreDataManager.saveVideos(videos)
                    print("Saved videos successfully")
                }
                page += 1
            }
        } catch {
            // 네트워크 요청 실패 시 에러 출력
            print("Failed to fetch videos: \(error.localizedDescription)")
        }

        isFetching = false
    }

    func resetPagination() {
         page = 1
         hasMore = true
     }

    func fetchVideosFromCoreData() -> [Video] {
        return coreDataManager.fetchRecommended()
    }

    /// CoreDataManager를 통해 모든 태그를 비동기적으로 가져옴
    /// 메인 스레드에서 `allTags` 프로퍼티에 저장
    func loadAllTags() async {
        let tags = await coreDataManager.fetchAllTags()
        await MainActor.run {
            self.allTags = tags
        }
    }
    
    // 실시간 갱신용(구현 예정)
    func filterTags(keyword: String) -> [Tag] {
        return allTags.filter { $0.name?.localizedCaseInsensitiveContains(keyword) == true }
    }
}
