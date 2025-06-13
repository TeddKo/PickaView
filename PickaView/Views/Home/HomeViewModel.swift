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

    func fetchVideosFromCoreData() -> [Video] {
        return coreDataManager.fetchRecommended()
    }


}
