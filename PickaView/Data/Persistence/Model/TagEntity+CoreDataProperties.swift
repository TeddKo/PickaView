//
//  TagEntity+CoreDataProperties.swift
//  PickaView
//
//  Created by 장지현 on 6/10/25.
//
//

import Foundation
import CoreData


extension TagEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TagEntity> {
        return NSFetchRequest<TagEntity>(entityName: "Tag")
    }

    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String?
    @NSManaged public var score: Double
    @NSManaged public var videos: NSSet?

}

// MARK: Generated accessors for videos
extension TagEntity {

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: VideoEntity)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: VideoEntity)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)

}

extension TagEntity : Identifiable {

}
