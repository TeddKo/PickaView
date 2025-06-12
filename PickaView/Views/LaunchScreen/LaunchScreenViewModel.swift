//
//  LaunchScreenViewModel.swift
//  PickaView
//
//  Created by 장지현 on 6/12/25.
//


import Foundation

final class LaunchScreenViewModel {
    let coreDataManager: CoreDataManager
    let pixabayVideoService: PixabayVideoService
    
    private let container: DIContainer

    init(coreDataManager: CoreDataManager, pixabayVideoService: PixabayVideoService, container: DIContainer) {
        self.coreDataManager = coreDataManager
        self.pixabayVideoService = pixabayVideoService
        self.container = container
    }

    func makeMainTabBarController() -> TabBarViewController {
        return container.makeMainTabBarController()
    }
}
