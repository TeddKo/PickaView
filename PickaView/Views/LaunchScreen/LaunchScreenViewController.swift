//
//  LaunchScreenViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await fetchAndSaveVideos()
        }
    }

    func fetchAndSaveVideos() async {
        do {
            // 1. Pixabay API에서 영상 데이터 fetch
            let videos = try await PixabayVideoService.shared.fetchVideos()

            print("✅ Pixabay에서 영상 \(videos.count)개를 받아왔습니다.")
            // TODO: CoreData 저장 등 추가 작업

        } catch {
            print("❌ 영상 fetch 오류: \(error.localizedDescription)")
        }
    }
    

}
