//
//  Int+Duration.swift
//  PickaView
//
//  Created by DONGNYEONG on 6/13/25.
//

import Foundation

// 비디오 길이를 "분:초" 형식으로 변환

extension Int {
    func toDurationString() -> String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
