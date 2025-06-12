//
//  TabBarViewModel.swift
//  PickaView
//
//  Created by 장지현 on 6/12/25.
//

import UIKit

final class TabBarViewModel {
    private let coreDataManager: CoreDataManager

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }

    func makeTabViewControllers() -> [UIViewController] {
//        let homeVM = HomeViewModel(coreDataManager: coreDataManager)
//        let homeVC = HomeViewController(viewModel: homeVM)
//        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
//
//        let likeVM = LikeViewModel(coreDataManager: coreDataManager)
//        let likeVC = LikeViewController(viewModel: likeVM)
//        likeVC.tabBarItem = UITabBarItem(title: "Like", image: UIImage(systemName: "heart.fill"), tag: 1)
//
//        let myPageVM = MyPageViewModel(coreDataManager: coreDataManager)
//        let myPageVC = MyPageViewController(viewModel: myPageVM)
//        myPageVC.tabBarItem = UITabBarItem(title: "MyPage", image: UIImage(systemName: "ellipsis"), tag: 2)

        return [
//            UINavigationController(rootViewController: homeVC),
//            UINavigationController(rootViewController: likeVC),
//            UINavigationController(rootViewController: myPageVC)
        ]
    }
}
