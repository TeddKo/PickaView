//
//  Tag+CoreDataProperties.swift
//  PickaView
//
//  Created by 장지현 on 6/10/25.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String?
    @NSManaged public var score: Double
    @NSManaged public var videos: NSSet?

}

// MARK: Generated accessors for videos
extension Tag {

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: Video)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: Video)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)

}

extension Tag : Identifiable {

}
