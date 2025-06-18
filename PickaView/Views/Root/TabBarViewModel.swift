//
//  TabBarViewModel.swift
//  PickaView
//
//  Created by 장지현 on 6/12/25.
//

import UIKit

/// 앱의 탭 바 컨트롤러에 필요한 뷰 컨트롤러들을 생성하는 뷰모델
///
/// 각 탭에 필요한 ViewModel을 초기화하고, 스토리보드에서 해당 ViewController를 생성한 후
/// UINavigationController로 감싼 배열을 반환
final class TabBarViewModel {
    let coreDataManager: CoreDataManager
    let pixabayVideoService: PixabayVideoService

    /// CoreDataManager와 PixabayVideoService를 초기화
    ///
    /// PixabayVideoService 초기화에 실패할 경우 앱을 중단
    init() {
        self.coreDataManager = CoreDataManager()
        do {
            self.pixabayVideoService = try PixabayVideoService()
        } catch {
            fatalError("PixabayVideoService 초기화 실패: \(error)")
        }
    }

    /// 탭 바에 표시할 각 뷰 컨트롤러를 생성하여 반환
    ///
    /// - Returns: 'UINavigationController'로 감싼 탭별 뷰 컨트롤러 배열
    func makeTabViewControllers() -> [UIViewController] {
        let homeVM = HomeViewModel(coreDataManager: coreDataManager, pixabayVideoService: pixabayVideoService)
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let homeVC = homeStoryboard.instantiateViewController(withIdentifier: String(describing: HomeViewController.self)) as! HomeViewController
        homeVC.viewModel = homeVM
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)

        let likeVM = LikeViewModel(coreDataManager: coreDataManager)
        let likeStoryboard = UIStoryboard(name: "Like", bundle: nil)
        let likeVC = likeStoryboard.instantiateViewController(withIdentifier: String(describing: LikeViewController.self)) as! LikeViewController
        likeVC.viewModel = likeVM
        likeVC.tabBarItem = UITabBarItem(title: "Like", image: UIImage(systemName: "heart.fill"), tag: 1)

        let myPageVM = MyPageViewModel(coreDataManager: coreDataManager)
        let myPageStoryboard = UIStoryboard(name: "MyPage", bundle: nil)
        let myPageVC = myPageStoryboard.instantiateViewController(withIdentifier: String(describing: MyPageViewController.self)) as! MyPageViewController
        myPageVC.viewModel = myPageVM
        myPageVC.tabBarItem = UITabBarItem(title: "MyPage", image: UIImage(systemName: "ellipsis"), tag: 2)
        
        return [
            UINavigationController(rootViewController: homeVC),
            UINavigationController(rootViewController: likeVC),
            UINavigationController(rootViewController: myPageVC)
        ]
    }
}
