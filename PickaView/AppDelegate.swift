//
//  AppDelegate.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        Task {
            await fetchAndTestVideos()
        }

        return true
    }

    func fetchAndTestVideos() async {
        do {
            let videos = try await PixabayVideoService.shared.fetchVideos()
            print("✅ AppDelegate에서 영상 \(videos.count)개 fetch 완료")
            // 👉 Core Data에 저장
            CoreDataManager.shared.saveVideos(videos)

            // 👉 저장 확인
            let savedVideos = CoreDataManager.shared.fetchAllVideos()
            print("📦 Core Data에 저장된 영상 수: \(savedVideos.count)")
            for video in savedVideos.prefix(3) { // 너무 많으면 일부만 출력
                print("🔹 저장된 Video - id: \(video.id), url: \(video.url ?? "없음")")
            }
        } catch {
            print("❌ AppDelegate 네트워크 오류: \(error.localizedDescription)")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

