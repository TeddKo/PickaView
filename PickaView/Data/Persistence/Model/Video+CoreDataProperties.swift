//
//  Video+CoreDataProperties.swift
//  PickaView
//
//  Created by 장지현 on 6/10/25.
//
//

import Foundation
import CoreData


extension Video {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }

    @NSManaged public var comments: Int64
    @NSManaged public var id: Int64
    @NSManaged public var downloads: Int64
    @NSManaged public var isLiked: Bool
    @NSManaged public var url: String?
    @NSManaged public var user: String?
    @NSManaged public var userID: String?
    @NSManaged public var userImageURL: String?
    @NSManaged public var views: Int64
    @NSManaged public var tags: Set<Tag>?
    @NSManaged public var timeStamp: TimeStamp?

}

// MARK: Generated accessors for tags
extension Video {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

extension Video : Identifiable {

}
