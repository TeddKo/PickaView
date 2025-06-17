//
//  TabBarViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/10/25.
//

import UIKit

class TabBarViewController: UITabBarController {
    private let viewModel = TabBarViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        ThemeManager.shared.applyTheme()
        viewControllers = viewModel.makeTabViewControllers()
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // 여러 번 호출하지 않도록 변수화 하여 한 번만 호출 후 캐싱 처리
        let mainColor = UIColor(named: "MainColor") ?? .systemBlue
        let unselectedColor = UIColor.gray

        // 선택된 아이템 스타일
        let selectedAppearance = appearance.stackedLayoutAppearance.selected
        selectedAppearance.iconColor = mainColor
        selectedAppearance.titleTextAttributes = [.foregroundColor: mainColor]

        // 선택되지 않은 아이템 스타일
        let normalAppearance = appearance.stackedLayoutAppearance.normal
        normalAppearance.iconColor = unselectedColor
        normalAppearance.titleTextAttributes = [.foregroundColor: unselectedColor]

        // iOS 15 이상 대응 -> 스크롤 엣지 설정
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
