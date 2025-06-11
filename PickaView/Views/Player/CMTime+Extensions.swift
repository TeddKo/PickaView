//
//  CMTime+Extensions.swift
//  PickaView
//
//  Created by junil on 6/10/25.
//

import AVKit

extension CMTime {
    /// CMTime 값을 "HH:mm:ss" 또는 "mm:ss" 형태의 문자열로 변환
    ///
    /// - Returns: 시간(초)을 "HH:mm:ss" 또는 "mm:ss" 포맷의 문자열로 반환
    func toTimeString() -> String {
        let roundedSeconds = seconds.rounded()
        let hours: Int = Int(roundedSeconds / 3600)
        let min: Int = Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let sec: Int = Int(roundedSeconds.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            // 1시간 이상일 때 "H:MM:SS" 포맷 반환
            return String(format: "%d:%02d:%02d", hours, min, sec)
        }

        // 1시간 미만일 때 "MM:SS" 포맷 반환
        return String(format: "%02d:%02d", min, sec)
    }
}
