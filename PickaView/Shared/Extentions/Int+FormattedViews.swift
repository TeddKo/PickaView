//
//  Int+FormattedViews.swift
//  PickaView
//
//  Created by DONGNYEONG on 6/17/25.
//
import Foundation

// 영상의 조회수를 포메팅하는 함수
extension BinaryInteger {
    func formattedViews() -> String {
        let num = Double(self)

        switch num {
        case 1_000_000...:
            let formatted = String(format: "%.1fM", num / 1_000_000)
            return formatted.replacingOccurrences(of: ".0", with: "") + " views"
        case 1_000...:
            let formatted = String(format: "%.1fK", num / 1_000)
            return formatted.replacingOccurrences(of: ".0", with: "") + " views"
        default:
            return "\(self) views"
        }
    }
}
