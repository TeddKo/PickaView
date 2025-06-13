//
//  HomeViewModel.swift
//  PickaView
//
//  Created by 장지현 on 6/13/25.
//

final class HomeViewModel {
    private let coreDataManager: CoreDataManager
    private let pixabayVideoService: PixabayVideoService

    init(coreDataManager: CoreDataManager, pixabayVideoService: PixabayVideoService) {
        self.coreDataManager = coreDataManager
        self.pixabayVideoService = pixabayVideoService
    }
}
