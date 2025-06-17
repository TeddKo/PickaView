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
    private var videoFRC: NSFetchedResultsController<Video>?
    /// 시청 기록(History) 목록을 효율적으로 가져오고 변경사항을 감지하는 Fetched Results Controller.
    private var historyFRC: NSFetchedResultsController<History>?

    /// 최근 시청한 비디오 목록이며, 컬렉션뷰에 표시될 데이터.
    @Published var watchedVideos: [Video] = []
    /// 최근 시청 기록이며, 차트 데이터로 사용됨.
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
        setupVideoFRC()
        setupHistoryFRC()
        updateHistoryData()
    }
    
    /// 시청 기록 비디오를 가져오기 위한 FRC(Fetched Results Controller)를 설정함.
    ///
    /// 시청 시작 시간이 있고 총 재생 시간이 0보다 큰 비디오를 대상으로,
    /// 가장 최근에 본 순서대로 정렬하여 가져옴.
    private func setupVideoFRC() {
        let predicate = NSPredicate(format: "timeStamp.startDate != NIL AND timeStamp.totalTime > 0")
        let sortDescriptors = [NSSortDescriptor(key: "timeStamp.startDate", ascending: false)]
        
        self.videoFRC = FRCFactory.makeVideoFRC(
            context: coreDataManager.mainContext,
            predicate: predicate,
            sortDescriptors: sortDescriptors,
            delegate: self
        )
    }
    
    /// FRC를 새로고침하여 CoreData로부터 최신 데이터를 다시 가져옴.
    ///
    /// 주로 뷰가 다시 나타날 때 호출되어 UI를 최신 상태로 유지하는 데 사용됨.
    func refreshFRC() {
        do {
            try videoFRC?.performFetch()
            try historyFRC?.performFetch()
            updateAllData()
        } catch {
            fatalError("FRC performFetch failed: \(error)")
        }
    }
    
    /// 시청 기록(History)을 가져오기 위한 FRC를 설정함.
    ///
    /// 모든 시청 기록을 날짜 내림차순으로 정렬하여 가져옴.
    private func setupHistoryFRC() {
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        self.historyFRC = FRCFactory.makeHistoryFRC(
            context: coreDataManager.mainContext,
            predicate: nil,
            sortDescriptors: sortDescriptors,
            delegate: self
        )
    }
    
    /// FRC로부터 가져온 최신 시청 기록(History)을 기반으로 관련 프로퍼티들을 모두 업데이트함.
    ///
    /// 이 메서드는 `weakHistory`, `todayWatchTimeString`, `weakWatchTimeString` 프로퍼티를 갱신함.
    private func updateHistoryData() {
        guard let histories = historyFRC?.fetchedObjects else { return }
        self.weakHistory = histories
        
        let today = Calendar.current.startOfDay(for: .now)
        let todayHistory = histories.first { history in
            guard let historyDate = history.date else { return false }
            return Calendar.current.isDate(historyDate, inSameDayAs: today)
        }
        
        let todaySeconds = todayHistory?.time ?? 0.0
        self.todayWatchTimeString = formatTime(duration: todaySeconds)
        
        let weakTotalSeconds = histories.reduce(0.0) { $0 + $1.time }
        self.weakWatchTimeString = formatTime(duration: weakTotalSeconds)
    }
    
    private func updateVideoData() {
        guard let video = videoFRC?.fetchedObjects else { return }
        self.watchedVideos = video
    }
    
    /// 뷰모델이 가진 모든 데이터 소스(비디오, 히스토리)를 새로고침함.
    private func updateAllData() {
        updateVideoData()
        updateHistoryData()
    }
    
    /// 초 단위 시간을 "Nh Nm Ss" 형식의 문자열로 변환함.
    ///
    /// - Parameter duration: 변환할 시간(초).
    /// - Returns: "1h 23m 45s"와 같은 형식의 시간 문자열을 반환함.
    private func formatTime(duration: Double) -> String {
        guard duration > 0 else { return "0s" }
        
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        var timeString = ""
        
        if hours > 0 {
            timeString += "\(hours)h "
        }
        if minutes > 0 || hours > 0 {
            timeString += "\(minutes)m "
        }
        timeString += "\(seconds)s"
        
        return timeString.trimmingCharacters(in: .whitespaces)
    }
    
    /// 이 뷰모델이 사용 중인 CoreDataManager 인스턴스를 반환함.
    ///
    /// 다른 뷰컨트롤러로 네비게이션할 때 데이터 관리자를 전달하기 위해 사용됨.
    /// - Returns: 현재 사용 중인 CoreDataManager 인스턴스.
    func getCoreDataManager() -> CoreDataManager {
        return coreDataManager
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension MyPageViewModel: NSFetchedResultsControllerDelegate {
    
    /// FRC가 CoreData의 콘텐츠 변경을 감지했을 때 호출되는 델리게이트 메서드.
    ///
    /// 변경된 컨트롤러가 `videoFRC`인지 `historyFRC`인지 판별하여 각각에 맞는 업데이트 로직을 수행함.
    /// - Parameter controller: 콘텐츠 변경을 보고하는 FRC(Fetched ResultsController).
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        if controller == videoFRC {
            if let fetchedObjects = controller.fetchedObjects as? [Video] {
                self.watchedVideos = Array(fetchedObjects.prefix(20))
            }
        } else if controller == historyFRC {
            updateHistoryData()
        }
    }
}
