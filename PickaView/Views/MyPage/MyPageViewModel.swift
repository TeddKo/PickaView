//
//  MyPageViewModel.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/15/25.
//

import Foundation
import Combine
import CoreData

/// 마이페이지 탭의 비즈니스 로직과 데이터를 관리하는 뷰모델.
///
/// CoreData로부터 시청 기록, 주간 시청 시간 등을 가져와 UI에 필요한 형태로 가공하고,
/// FRC를 통해 데이터 변경을 감지하여 UI를 업데이트함.
class MyPageViewModel: NSObject, ObservableObject {
    /// CoreData 영속성 컨테이너를 관리하는 객체.
    private let coreDataManager: CoreDataManager
    /// 시청한 비디오 목록을 효율적으로 가져오고 변경사항을 감지하는 Fetched Results Controller.
    private var frc: NSFetchedResultsController<Video>?
    
    /// 최근 시청한 비디오 목록. 컬렉션뷰에 표시될 데이터임.
    @Published var watchedVideos: [Video] = []
    /// 최근 7일간의 시청 기록. 차트 데이터로 사용됨.
    @Published var weakHistory: [History] = []
    /// 오늘 하루의 총 시청 시간을 나타내는 포맷된 문자열.
    @Published var todayWatchTimeString: String = ""
    /// 최근 7일간의 총 시청 시간을 나타내는 포맷된 문자열.
    @Published var weakWatchTimeString: String = ""
    
    /// MyPageViewModel의 새 인스턴스를 초기화함.
    ///
    /// - Parameter coreDataManager: 의존성으로 주입되는 CoreDataManager 인스턴스.
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init()
        setupFRC()
    }
    
    /// 시청 기록 비디오를 가져오기 위한 FRC(Fetched Results Controller)를 설정함.
    ///
    /// 시청 시작 시간이 있고 총 재생 시간이 0보다 큰 비디오를 대상으로,
    /// 가장 최근에 본 순서대로 정렬하여 가져옴.
    private func setupFRC() {
        let predicate = NSPredicate(format: "timeStamp.startDate != NIL AND timeStamp.totalTime > 0")
        let sortDescriptors = [NSSortDescriptor(key: "sortTimeStamp", ascending: false)]

        self.frc = FRCFactory.makeVideoFRC(
            context: coreDataManager.mainContext,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            delegate: self
        )
        
        if let fetchedObjects = frc?.fetchedObjects {
            self.watchedVideos = Array(fetchedObjects.prefix(20))
        }
    }
    
    /// FRC를 새로고침하여 CoreData로부터 최신 데이터를 다시 가져옴.
    ///
    /// 주로 뷰가 다시 나타날 때 호출되어 UI를 최신 상태로 유지하는 데 사용됨.
    func refreshFRC() {
            do {
                try frc?.performFetch()
                if let fetchedObjects = frc?.fetchedObjects {
                    self.watchedVideos = Array(fetchedObjects.prefix(20))
                }
            } catch {
                print("FRC performFetch failed: \(error)")
            }
        }
    
    /// 최근 7일간의 시청 기록(History) 데이터를 가져와 관련 프로퍼티를 업데이트함.
    ///
    /// 차트 데이터, 오늘 시청 시간, 주간 시청 시간 등을 계산하여 UI에 반영될 수 있도록 함.
    func fetchWeakHistory() {
        let histories = coreDataManager.fetchHistory()
        
        self.weakHistory = histories
        
        let today = Calendar.current.startOfDay(for: Date())
        let todayHistory = histories.first { history in
            guard let historyDate = history.date else { return false }
            return Calendar.current.isDate(historyDate, inSameDayAs: today)
        }
        let todaySeconds = todayHistory?.time ?? 0.0
        self.todayWatchTimeString = formatTime(seconds: todaySeconds)
        
        let weakTotalSeconds = histories.reduce(0.0) { $0 + $1.time }
        self.weakWatchTimeString = formatTime(seconds: weakTotalSeconds)
    }
    
    /// 초 단위 시간을 "Nh Nm" 또는 "Nm" 형식의 문자열로 변환함.
    ///
    /// - Parameter seconds: 변환할 시간(초 단위).
    /// - Returns: 변환된 시간 문자열.
    private func formatTime(seconds: Double) -> String {
            guard seconds > 0 else { return "0m" }
            
            let totalSeconds = Int(seconds)
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes)m"
            }
        }
    
    /// 뷰모델이 소유한 CoreDataManager 인스턴스를 반환함.
    ///
    /// 다른 뷰컨트롤러(예: PlayerViewController)로 전환 시 CoreDataManager를 전달하기 위해 사용됨.
    /// - Returns: CoreDataManager 인스턴스.
    func getCoreDataManager() -> CoreDataManager {
        return coreDataManager
    }
}

/// FRC의 데이터 변경을 감지하기 위한 NSFetchedResultsControllerDelegate 구현.
extension MyPageViewModel: NSFetchedResultsControllerDelegate {
    /// FRC가 감지한 CoreData의 콘텐츠 변경이 완료되었을 때 호출됨.
    ///
    /// `watchedVideos` 프로퍼티를 최신 데이터로 업데이트하여 UI가 새로고침되도록 함.
    /// - Parameter controller: 콘텐츠 변경을 보고하는 FRC.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        if let fetchedObjects = controller.fetchedObjects as? [Video] {
            self.watchedVideos = Array(fetchedObjects.prefix(20))
        }
    }
}
