//
//  FRCFactory.swift
//  PickaView
//
//  Created by 장지현 on 6/13/25.
//

import Foundation
import CoreData

/// `NSFetchedResultsController` (FRC) 인스턴스를 생성하는 팩토리 열거형.
///
/// FRC 생성과 관련된 반복적인 코드를 캡슐화하고 재사용성을 높임.
enum FRCFactory {
    
    /// `Video` 엔티티에 대한 `NSFetchedResultsController`를 생성하여 반환함.
    /// - Parameters:
    ///   - context: FRC가 사용할 `NSManagedObjectContext`.
    ///   - predicate: 데이터 필터링을 위한 `NSPredicate` (옵션).
    ///   - sortDescriptors: 데이터 정렬을 위한 `NSSortDescriptor` 배열 (기본값: id 오름차순).
    ///   - cacheName: FRC의 캐시 파일 이름 (옵션). 성능 향상에 사용될 수 있음.
    ///   - delegate: FRC의 데이터 변경을 감지할 델리게이트 (옵션).
    /// - Returns: 설정이 완료된 `NSFetchedResultsController<Video>` 인스턴스.
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
    
    /// `History` 엔티티에 대한 `NSFetchedResultsController`를 생성하여 반환함.
    /// - Parameters:
    ///   - context: FRC가 사용할 `NSManagedObjectContext`.
    ///   - predicate: 데이터 필터링을 위한 `NSPredicate` (옵션).
    ///   - sortDescriptors: 데이터 정렬을 위한 `NSSortDescriptor` 배열 (기본값: date 오름차순).
    ///   - cacheName: FRC의 캐시 파일 이름 (옵션). 성능 향상에 사용될 수 있음.
    ///   - delegate: FRC의 데이터 변경을 감지할 델리게이트 (옵션).
    /// - Returns: 설정이 완료된 `NSFetchedResultsController<History>` 인스턴스.
    static func makeHistoryFRC(
        context: NSManagedObjectContext,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "date", ascending: true)],
        cacheName: String? = nil,
        delegate: NSFetchedResultsControllerDelegate? = nil
    ) -> NSFetchedResultsController<History> {
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
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
