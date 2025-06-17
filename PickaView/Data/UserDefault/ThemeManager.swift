//
//  UserDefault.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/10/25.
//

import UIKit

/// 앱의 인터페이스 스타일(테마)을 관리하는 싱글턴 클래스.
final class ThemeManager {
    
    /// `ThemeManager`의 유일한 인스턴스에 접근하기 위한 정적 프로퍼티.
    static let shared = ThemeManager()
    
    /// `UserDefaults`에 테마 설정을 저장하기 위한 키.
    private let themeKey = "appTheme"
    
    /// 가독성을 위해 정수 인덱스 대신 사용하는 테마 옵션 열거형.
    enum ThemeOption: Int {
        case light = 0
        case dark = 1
        case system = 2
    }
    
    /// 외부에서 인스턴스를 직접 생성하지 못하도록 private으로 선언됨.
    private init() {}
    
    /// `UserDefaults`에 저장된 현재 테마 인덱스를 불러오는 계산 프로퍼티.
    var currentThemeIndex: Int {
        if UserDefaults.standard.object(forKey: themeKey) == nil {
            return ThemeOption.system.rawValue
        }
        
        return UserDefaults.standard.integer(forKey: themeKey)
    }
    
    /// 저장된 테마 설정을 앱의 모든 윈도우에 즉시 적용함.
    ///
    /// 앱이 시작될 때 `TabBarViewController`에서 호출됨.
    func applyTheme() {
        let themeIndex = UserDefaults.standard.integer(forKey: themeKey)
        guard let theme = ThemeOption(rawValue: themeIndex) else { return }
        
        let style: UIUserInterfaceStyle
        switch theme {
        case .light: style = .light
        case .dark: style = .dark
        case .system: style = .unspecified
        }
        
        UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .forEach { windowScene in
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = style
                }
            }
    }
    
    /// 새로운 테마 설정을 저장하고 즉시 적용함.
    ///
    /// `MyPageViewController`의 세그먼트 컨트롤에서 호출됨.
    /// - Parameter selectedIndex: 사용자가 선택한 새로운 테마의 인덱스.
    func setTheme(selectedIndex: Int) {
        UserDefaults.standard.set(selectedIndex, forKey: themeKey)
        applyTheme()
    }
}
