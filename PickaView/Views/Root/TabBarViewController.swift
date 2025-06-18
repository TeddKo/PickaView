//
//  TabBarViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/10/25.
//

import UIKit

// 스크롤 최상단 이동을 위한 프로토콜 정의
protocol ScrollToTopCapable {
    func scrollToTop()
}

/// 앱의 메인 탭 바 컨트롤러
///
/// 각 탭에 대한 뷰 컨트롤러를 설정하고, 탭이 다시 선택되었을 때 최상단으로 스크롤하는 기능을 제공
class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    private let viewModel = TabBarViewModel()
    private var lastSelectedIndex: Int = 0

    /// 초기 탭 바 설정을 구성
    ///
    /// 테마를 적용하고, 탭 바 외관을 설정한 뒤 뷰 컨트롤러들을 구성
    override func viewDidLoad() {
        super.viewDidLoad()
        // UITabBarController가 탭 선택 이벤트가 발생했을 때 didSelect를 호출
        delegate = self
        ThemeManager.shared.applyTheme()
        setupTabBarAppearance()
        viewControllers = viewModel.makeTabViewControllers()
    }

    /// 탭 바의 색상과 외관을 설정
    ///
    /// 선택된 항목과 선택되지 않은 항목의 색상을 지정하며, iOS 15 이상에서는 `scrollEdgeAppearance`를 적용
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        // 여러 번 호출하지 않도록 변수화 하여 한 번만 호출 후 캐싱 처리
        let mainColor = UIColor(named: "MainColor") ?? .systemBlue
        let unselectedColor = UIColor.gray

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = mainColor
        selected.titleTextAttributes = [.foregroundColor: mainColor]

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = unselectedColor
        normal.titleTextAttributes = [.foregroundColor: unselectedColor]

        tabBar.standardAppearance = appearance
        // iOS 15 이상 대응 -> 스크롤 엣지 설정
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    /// 동일한 탭이 다시 선택되었을 때 스크롤을 최상단으로 이동
    ///
    /// `ScrollToTopCapable` 프로토콜을 구현한 뷰 컨트롤러에서만 동작
    ///
    /// - Parameters:
    ///   - tabBarController: 현재 탭 바 컨트롤러
    ///   - viewController: 선택된 탭의 뷰 컨트롤러
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController) else { return }
        // 선택된 인덱스가 마지막으로 선택된 인덱스와 같을 때만 스크롤 최상단으로 이동
        if index == lastSelectedIndex {
            switch viewController {
            case let nav as UINavigationController:
                if let topVC = nav.topViewController as? ScrollToTopCapable {
                    topVC.scrollToTop()
                }
            case let vc as ScrollToTopCapable:
                vc.scrollToTop()
            default:
                break
            }
        }
        lastSelectedIndex = index
    }
}
