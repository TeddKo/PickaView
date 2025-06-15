//
//  LikeViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/11/25.
//

import UIKit

/**
 사용자가 '좋아요'한 비디오 목록을 표시하는 뷰 컨트롤러.

 이 뷰 컨트롤러는 UICollectionView를 사용하여 '좋아요' 목록을 그리드 형태로 보여주며,
 기기 종류(아이폰/아이패드) 및 화면 방향(세로/가로)에 따라 동적으로 레이아웃을 조정함.
 */
class LikeViewController: UIViewController {

    /** '좋아요' 목록을 표시할 UICollectionView. 스토리보드에서 연결됨. */
    @IBOutlet weak var collectionView: UICollectionView!

    var viewModel: LikeViewModel!

    var selectedIndexPath: IndexPath?

    /// 뷰 로드 후 초기 설정 및 테스트용 더미 좋아요 주입
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        collectionView.dataSource = self
        collectionView.delegate = self

        // 테스트: CoreData 전체 영상 중 일부를 좋아요 처리
        let allVideos = viewModel.coreDataManager.fetch()
        for index in 0..<min(allVideos.count, 100) {
            viewModel.coreDataManager.updateIsLiked(for: allVideos[index], isLiked: true)
        }

        viewModel.fetchLikedVideos()
        print("🔥 최종 좋아요 개수: \(viewModel.likeCount)")

        collectionView.reloadData()
    }

    /**
     기기 회전 등 뷰의 크기가 변경될 때 호출됨.
     - Parameters:
     - size: 뷰가 전환될 새로운 크기.
     - coordinator: 전환 애니메이션을 관리하는 코디네이터.
     */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard isViewLoaded else { return }
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
}

extension LikeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /**
     지정된 섹션에 표시할 아이템(셀)의 수를 반환함.
     - Parameters:
     - collectionView: 이 메서드를 요청하는 컬렉션뷰.
     - section: 아이템 개수가 필요한 섹션의 인덱스.
     - Returns: 섹션에 포함될 아이템의 총 개수.
     */
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.likeCount
    }

    /**
     지정된 인덱스 경로에 대한 셀을 생성하고 구성하여 반환함.
     - Parameters:
     - collectionView: 이 메서드를 요청하는 컬렉션뷰.
     - indexPath: 셀의 위치를 나타내는 인덱스 경로.
     - Returns: 구성이 완료된 `UICollectionViewCell`.
     */
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "LikeCollectionViewCell",
            for: indexPath
        ) as? LikeCollectionViewCell else {
            return UICollectionViewCell()
        }

        if let cellData = viewModel.cellData(at: indexPath.item) {
            cell.configure(
                like: DummyLike(
                    date: cellData.date,
                    thumbnailURL: cellData.thumbnailURL,
                    videoLength: Double(cellData.videoLength),
                    tags: cellData.tags
                )
            )
        }

        return cell
    }

    /**
     지정된 인덱스 경로에 있는 아이템의 크기를 계산하여 반환함.

     다른 델리게이트 메서드로부터 여백(inset)과 아이템 간 간격(spacing) 정보를 가져와
     사용 가능한 전체 너비를 계산하고, 이를 기반으로 셀의 크기를 동적으로 결정함.
     - Parameters:
     - collectionView: 이 메서드를 요청하는 컬렉션뷰.
     - collectionViewLayout: 레이아웃 정보를 관리하는 객체.
     - indexPath: 크기를 계산할 아이템의 인덱스 경로.
     - Returns: 아이템의 계산된 크기.
     */
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath:IndexPath
    ) -> CGSize {

        // 다른 델리게이트 메서드로부터 여백과 간격 값을 가져옴
        let insets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let interitemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)

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

    /**
     지정된 섹션의 콘텐츠 인셋(여백)을 결정함.
     - Parameters:
     - collectionView: 이 메서드를 요청하는 컬렉션뷰.
     - collectionViewLayout: 레이아웃 정보를 관리하는 객체.
     - section: 인셋을 적용할 섹션의 인덱스.
     - Returns: 섹션에 적용할 여백.
     */
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .init(horizontal: 16)
    }

    /**
     같은 행에 있는 아이템들 사이의 최소 수평 간격을 결정함.
     - Parameters:
     - collectionView: 이 메서드를 요청하는 컬렉션뷰.
     - collectionViewLayout: 레이아웃 정보를 관리하는 객체.
     - section: 간격을 적용할 섹션의 인덱스.
     - Returns: 아이템 간의 최소 수평 간격.
     */
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        let isPhonePortrait = traitCollection.userInterfaceIdiom == .phone && view.bounds.width < view.bounds.height
        // 아이폰 세로 모드에서는 간격 없음, 그 외에는 16의 간격을 줌
        return isPhonePortrait ? 0 : 16
    }

    /**
     컬렉션뷰의 다른 행에 있는 아이템들 사이의 최소 수직 간격을 결정함.
     - Parameters:
     - collectionView: 이 메서드를 요청하는 컬렉션뷰.
     - collectionViewLayout: 레이아웃 정보를 관리하는 객체.
     - section: 간격을 적용할 섹션의 인덱스.
     - Returns: 행 간의 최소 수직 간격.
     */
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 24
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedVideo = viewModel.video(at: indexPath.item) else { return }

        let playerVC = PlayerViewController()
        playerVC.viewModel = PlayerViewModel(video: selectedVideo)
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true, completion: nil)
    }
}
