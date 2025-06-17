//
//  MyPageHistoriesViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/11/25.
//

import UIKit

/// '시청 기록 전체 보기' 화면을 표시하고 관리하는 뷰 컨트롤러.
class MyPageHistoriesViewController: UIViewController {
    
    /// 시청 기록 목록을 표시하는 컬렉션뷰. 스토리보드에 연결됨.
    @IBOutlet weak var historiesColletionView: UICollectionView!
    
    /// CoreData 영속성 컨테이너를 관리하는 객체. 이전 화면에서 주입받음.
    var coreDataManager: CoreDataManager?
    /// 컬렉션뷰에 표시될 시청 기록 비디오 목록. 이전 화면에서 주입받음.
    var watchedVideos: [Video] = []
    
    /// 뷰가 메모리에 로드된 후 호출되는 생명주기 메서드.
    ///
    /// 초기 UI 설정 및 데이터가 없을 경우 `EmptyView`를 표시함.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        emptyView()
    }
    
    /// 기기 회전 등 뷰의 크기가 변경될 때 호출됨.
    ///
    /// 컬렉션뷰 레이아웃을 무효화하여 새로운 크기에 맞게 셀을 다시 계산하도록 함.
    /// - Parameters:
    ///   - size: 뷰가 전환될 새로운 크기.
    ///   - coordinator: 전환 애니메이션을 관리하는 코디네이터.
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard isViewLoaded else { return }
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self else { return }
            self.historiesColletionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    /// `watchedVideos` 배열이 비어있는지 확인하고, 비어있을 경우 컬렉션뷰의 배경으로 `EmptyView`를 설정함.
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
    
    /// 지정된 섹션에 표시할 아이템의 총 개수를 반환함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - section: 아이템 개수를 요청하는 섹션의 인덱스.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return watchedVideos.count
    }
    
    /// 특정 `indexPath`에 해당하는 셀을 생성하고 구성하여 반환함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - indexPath: 셀을 요청하는 위치의 인덱스 경로.
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
            cell.configure(with: video)
        }
        return cell
    }
    
    /// 지정된 인덱스 경로에 있는 아이템의 크기를 계산하여 반환함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - collectionViewLayout: 레이아웃 정보를 관리하는 객체.
    ///   - indexPath: 크기를 계산할 아이템의 인덱스 경로.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
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
        
        let itemsPerRow: CGFloat = isPad ? (isPortrait ? 2 : 3) : (isPortrait ? 1 : 2)
        
        let totalHorizontalSpacing = insets.left + insets.right + (interitemSpacing * (itemsPerRow - 1))
        
        let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / itemsPerRow
        let itemHeight = itemWidth * 0.4
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    /// 지정된 섹션의 콘텐츠 인셋(여백)을 결정함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - collectionViewLayout: 레이아웃 정보를 관리하는 객체.
    ///   - section: 인셋을 적용할 섹션의 인덱스.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .init(horizontal: 16)
    }
    
    /// 같은 행에 있는 아이템들 사이의 최소 수평 간격을 결정함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - collectionViewLayout: 레이아웃 정보를 관리하는 객체.
    ///   - section: 간격을 적용할 섹션의 인덱스.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        let isPhonePortrait = traitCollection.userInterfaceIdiom == .phone && view.bounds.width < view.bounds.height
        return isPhonePortrait ? 0 : 16
    }
    
    /// 컬렉션뷰의 다른 행에 있는 아이템들 사이의 최소 수직 간격을 결정함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - collectionViewLayout: 레이아웃 정보를 관리하는 객체.
    ///   - section: 간격을 적용할 섹션의 인덱스.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 24
    }
    
    /// 사용자가 특정 셀을 선택했을 때 호출됨.
    ///
    /// 선택된 비디오의 플레이어 화면으로 전환함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - indexPath: 선택된 셀의 위치를 나타내는 인덱스 경로.
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
