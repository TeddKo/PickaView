//
//  CMTime+Extensions.swift
//  PickaView
//
//  Created by junil on 6/10/25.
//

import AVKit

extension CMTime {
    /// 현재 CMTime 값을 "HH:mm:ss" 또는 "mm:ss" 문자열로 변환
    ///
    /// - Returns: 시간 포맷 문자열 (예: "01:23" 또는 "1:02:03")
    func toTimeString() -> String {
        let roundedSeconds = seconds.rounded()
        let hours: Int = Int(roundedSeconds / 3600)
        let min: Int = Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let sec: Int = Int(roundedSeconds.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, min, sec)
        }

        return String(format: "%02d:%02d", min, sec)
    }
}
