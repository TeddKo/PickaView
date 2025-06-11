//
//  AppOrientationManager.swift
//  PickaView
//
//  Created by junil on 6/10/25.
//

import UIKit

/// 앱의 화면 방향 상태를 전역적으로 관리하는 구조체
struct AppOrientationManager {
    /// 현재 앱이 지원해야 하는 화면 방향을 저장하는 정적 변수
    static var supportedOrientations: UIInterfaceOrientationMask = .portrait
}
