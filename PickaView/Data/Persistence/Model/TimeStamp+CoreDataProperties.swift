//
//  TimeStamp+CoreDataProperties.swift
//  PickaView
//
//  Created by 장지현 on 6/10/25.
//
//

import Foundation
import CoreData


extension TimeStamp {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimeStamp> {
        return NSFetchRequest<TimeStamp>(entityName: "TimeStamp")
    }

    @NSManaged public var endTime: Date?
    @NSManaged public var startTime: Date?
    @NSManaged public var whole: Double
    @NSManaged public var video: Video?

}

extension TimeStamp : Identifiable {

}
