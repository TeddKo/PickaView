//
//  CoreDataManager.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores { desc, error in
            if let error = error {
                fatalError("Core Data load error: \(error.localizedDescription)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Core Data 저장 성공")
            } catch {
                print("❌ Core Data 저장 실패: \(error.localizedDescription)")
            }
        }
    }

    func fetchAllVideos() -> [Video] {
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()

        do {
            let videos = try context.fetch(fetchRequest)
            return videos
        } catch {
            print("❌ Core Data fetch 실패: \(error.localizedDescription)")
            return []
        }
    }

    func saveVideos(_ videos: [PixabayVideo]) {
        let context = persistentContainer.viewContext

        for video in videos {
            let videoId = Int64(video.id)

            let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", videoId)

            if let existingVideo = try? context.fetch(fetchRequest).first {
                existingVideo.url = video.videos.medium.url
                existingVideo.comments = Int64(video.comments)
                existingVideo.user = video.user
                existingVideo.userID = String(video.userID)
                existingVideo.userImageURL = video.userImageURL
                existingVideo.views = Int64(video.views)
            } else {
                let newVideo = Video(context: context)
                newVideo.id = videoId
                newVideo.url = video.videos.medium.url
                newVideo.comments = Int64(video.comments)
                newVideo.user = video.user
                newVideo.userID = String(video.userID)
                newVideo.userImageURL = video.userImageURL
                newVideo.views = Int64(video.views)
            }
        }
        saveContext()
    }

}
