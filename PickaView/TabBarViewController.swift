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

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    private let viewModel = TabBarViewModel()
    private var lastSelectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // UITabBarController가 탭 선택 이벤트가 발생했을 때 didSelect를 호출
        delegate = self
        ThemeManager.shared.applyTheme()
        setupTabBarAppearance()
        viewControllers = viewModel.makeTabViewControllers()
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        let mainColor = UIColor(named: "MainColor") ?? .systemBlue
        let unselectedColor = UIColor.gray

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = mainColor
        selected.titleTextAttributes = [.foregroundColor: mainColor]

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = unselectedColor
        normal.titleTextAttributes = [.foregroundColor: unselectedColor]

        tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    // UITabBarControllerDelegate 메서드 추가
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
