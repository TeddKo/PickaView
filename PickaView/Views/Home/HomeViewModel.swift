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
            print("📡 비디오 가져오기 시작: query = \(query ?? "없음")")
            let videos = try await pixabayVideoService.fetchVideos(query: query)
            print("✅ 비디오 가져오기 완료: \(videos.count)개")

            await MainActor.run {
                print("💾 CoreData에 저장 시작")
                self.coreDataManager.saveVideos(videos)
                print("✅ CoreData에 저장 완료")
            }
        } catch {
            print("❌ 네트워크 요청 실패: \(error.localizedDescription)")
        }
    }

    func fetchVideosFromCoreData() -> [Video] {
        return coreDataManager.fetch()
    }


}
