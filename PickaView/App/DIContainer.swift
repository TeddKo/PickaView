//
//  DIContainer.swift
//  PickaView
//
//  Created by 장지현 on 6/12/25.
//

import UIKit

final class DIContainer {
    let coreDataManager: CoreDataManager
    let pixabayVideoService: PixabayVideoService

    init() {
        self.coreDataManager = CoreDataManager()
        self.pixabayVideoService = PixabayVideoService()
    }

    func makeLaunchScreenViewController() -> LaunchScreenViewController {
        let viewModel = LaunchScreenViewModel(
            coreDataManager: coreDataManager,
            pixabayVideoService: pixabayVideoService,
            container: self
        )
        return LaunchScreenViewController(viewModel: viewModel)
    }

    func makeMainTabBarController() -> TabBarViewController {
        let viewModel = TabBarViewModel(coreDataManager: coreDataManager)
        return TabBarViewController(viewModel: viewModel)
    }
}
