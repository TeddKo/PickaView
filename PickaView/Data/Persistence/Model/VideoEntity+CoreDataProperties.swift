//
//  VideoEntity+CoreDataProperties.swift
//  PickaView
//
//  Created by 장지현 on 6/10/25.
//
//

import Foundation
import CoreData

extension VideoEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoEntity> {
        return NSFetchRequest<VideoEntity>(entityName: "Video")
    }

    @NSManaged public var comments: Int64
    @NSManaged public var downloads: Int64
    @NSManaged public var id: Int64
    @NSManaged public var isLiked: Bool
    @NSManaged public var url: String?
    @NSManaged public var user: String?
    @NSManaged public var userID: String?
    @NSManaged public var userImageURL: String?
    @NSManaged public var views: Int64
    @NSManaged public var tags: Set<TagEntity>?
    @NSManaged public var timeStamp: TimeStampEntity?
}

// MARK: Generated accessors for tags
extension VideoEntity {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: TagEntity)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: TagEntity)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}

extension VideoEntity : Identifiable {

}
