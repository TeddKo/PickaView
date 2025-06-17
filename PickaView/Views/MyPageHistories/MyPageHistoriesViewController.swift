//
//  MyPageHistoriesViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/11/25.
//

import UIKit

class MyPageHistoriesViewController: UIViewController {
    @IBOutlet weak var historiesColletionView: UICollectionView!
    
    var coreDataManager: CoreDataManager?
    var watchedVideos: [Video] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        emptyView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard isViewLoaded else { return }
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self else { return }
            self.historiesColletionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func emptyView() {
        if watchedVideos.isEmpty {
            let emptyView = EmptyView()
            emptyView
                .configure(
                    systemName: "video.slash",
                    title: "No watch history yet",
                    description: "Tap a video\n to start building your history"
                )
            self.historiesColletionView.backgroundView = emptyView
        } else {
            self.historiesColletionView.backgroundView = nil
        }
        self.historiesColletionView.reloadData()
    }
}

extension MyPageHistoriesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return watchedVideos.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "HistoriesCollectionViewCell",
            for: indexPath
        ) as? MyPageHistoriesCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if !watchedVideos.isEmpty {
            let video = watchedVideos[indexPath.item]
            cell.configure(width: video)
        }
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        // 다른 델리게이트 메서드로부터 여백과 간격 값을 가져옴
        let insets = self.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: indexPath.section
        )
        let interitemSpacing = self.collectionView(
            collectionView,
            layout: collectionViewLayout,
            minimumInteritemSpacingForSectionAt: indexPath.section
        )
        
        let isPad = traitCollection.userInterfaceIdiom == .pad
        let isPortrait = view.bounds.width < view.bounds.height
        
        // 한 줄에 표시할 아이템 개수 결정
        let itemsPerRow: CGFloat = isPad ? (isPortrait ? 2 : 3) : (isPortrait ? 1 : 2)
        
        // 여백과 아이템 간 간격을 모두 합산하여 수평 방향의 총 여백을 계산
        let totalHorizontalSpacing = insets.left + insets.right + (interitemSpacing * (itemsPerRow - 1))
        
        // 컬렉션뷰의 전체 너비에서 총 수평 여백을 뺀 후, 아이템 개수로 나누어 각 아이템의 너비를 계산
        let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / itemsPerRow
        let itemHeight = itemWidth * 0.4
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .init(horizontal: 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        let isPhonePortrait = traitCollection.userInterfaceIdiom == .phone && view.bounds.width < view.bounds.height
        // 아이폰 세로 모드에서는 간격 없음, 그 외에는 16의 간격을 줌
        return isPhonePortrait ? 0 : 16
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 24
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let coreDataManager = self.coreDataManager, watchedVideos.indices.contains(indexPath.item) else { return }
        let selectedVideo = watchedVideos[indexPath.item]
        
        let storyboard = UIStoryboard(name: "Player", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController else { return }
        
        playerVC.viewModel = PlayerViewModel(video: selectedVideo, coreDataManager: coreDataManager)
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true, completion: nil)
    }
}
