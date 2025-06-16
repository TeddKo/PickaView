//
//  FRCFactory.swift
//  PickaView
//
//  Created by 장지현 on 6/13/25.
//

import Foundation
import CoreData

enum FRCFactory {
    static func makeVideoFRC(
        context: NSManagedObjectContext,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "id",ascending: true)],
        cacheName: String? = nil,
        delegate: NSFetchedResultsControllerDelegate? = nil
    ) -> NSFetchedResultsController<Video> {
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: cacheName
        )
        
        frc.delegate = delegate
        
        do {
            try frc.performFetch()
        } catch {
            print("❌ NSFetchedResultsController fetch 실패: \(error.localizedDescription)")
        }
        return frc
    }
}
