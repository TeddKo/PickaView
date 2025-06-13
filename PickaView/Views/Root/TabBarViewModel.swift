//
//  TabBarViewModel.swift
//  PickaView
//
//  Created by 장지현 on 6/12/25.
//

import UIKit

final class TabBarViewModel {
    let coreDataManager: CoreDataManager
    let pixabayVideoService: PixabayVideoService

    init() {
        self.coreDataManager = CoreDataManager()
        do {
            self.pixabayVideoService = try PixabayVideoService()
        } catch {
            fatalError("PixabayVideoService 초기화 실패: \(error)")
        }
    }

    func makeTabViewControllers() -> [UIViewController] {
        let homeVM = HomeViewModel(coreDataManager: coreDataManager, pixabayVideoService: pixabayVideoService)
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let homeVC = homeStoryboard.instantiateViewController(withIdentifier: String(describing: HomeViewController.self)) as! HomeViewController
        homeVC.viewModel = homeVM
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)

//        let likeVM = LikeViewModel(coreDataManager: coreDataManager)
        let likeStoryboard = UIStoryboard(name: "Like", bundle: nil)
        let likeVC = likeStoryboard.instantiateViewController(withIdentifier: String(describing: LikeViewController.self)) as! LikeViewController
//        likeVC.viewModel = likeVM
        likeVC.tabBarItem = UITabBarItem(title: "Like", image: UIImage(systemName: "heart.fill"), tag: 1)

//        let myPageVM = MyPageViewModel(coreDataManager: coreDataManager)
        let myPageStoryboard = UIStoryboard(name: "MyPage", bundle: nil)
        let myPageVC = myPageStoryboard.instantiateViewController(withIdentifier: String(describing: MyPageViewController.self)) as! MyPageViewController
//        myPageVC.viewModel = myPageVM
        myPageVC.tabBarItem = UITabBarItem(title: "MyPage", image: UIImage(systemName: "ellipsis"), tag: 2)
        
        return [
            UINavigationController(rootViewController: homeVC),
            UINavigationController(rootViewController: likeVC),
            UINavigationController(rootViewController: myPageVC)
        ]
    }
}
