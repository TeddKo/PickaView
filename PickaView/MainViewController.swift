//
//  MainViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/10/25.
//

import UIKit

class MainViewController: UITabBarController {
    
    let coreDataManager = CoreDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeManager.shared.applyTheme()
        print("initial")
        
        if let viewControllers = viewControllers {
            for vc in viewControllers {
                if let nav = vc as? UINavigationController, let topVC = nav.topViewController {
                    injectViewModel(to: topVC)
                } else {
                    injectViewModel(to: vc)
                }
            }
        }
    }
    
    private func injectViewModel(to viewController: UIViewController) {
//        switch viewController {
//        case let vc as HomeViewController:
//            vc.viewModel = HomeViewModel(coreDataManager: coreDataManager)
//        case let vc as LikeViewController:
//            vc.viewModel = LikeViewModel(coreDataManager: coreDataManager)
//        case let vc as MyPageViewController:
//            vc.viewModel = MyPageViewController(coreDataManager: coreDataManager)
//        case let vc as PlayerViewController:
//            vc.viewModel = PlayerViewController(coreDataManager: coreDataManager)
//        }
    }
}
