//
//  TabBarViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/10/25.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeManager.shared.applyTheme()
        print("initial")
        
        setupTabBar()
    }
    
    private func setupTabBar() {
//        let homeVM = HomeViewModel(coreDataManager: coreDataManager)
//        let homeVC = HomeViewController(viewModel: homeVM)
//        homeVC.tabBarItem = UITabBarItem(title: "Home", image: "house.fill", tag: 0)
//        
//        let likeVM = LikeViewModel(coreDataManager: coreDataManager)
//        let likeVC = LikeViewController(viewModel: likeVM)
//        likeVC.tabBarItem = UITabBarItem(title: "Like", image: "heart.fill", tag: 1)
//        
//        let myPageVM = MyPageViewModel(coreDataManager: coreDataManager)
//        let myPageVC = MyPageViewController(viewModel: myPageVM)
//        myPageVC.tabBarItem = UITabBarItem(title: "MyPage", image: "ellipsis", tag: 2)
//
//        viewControllers = [
//            UINavigationController(rootViewController: homeVC),
//            UINavigationController(rootViewController: likeVC),
//            UINavigationController(rootViewController: myPageVC)
//        ]
    }
}
