//
//  LikeViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/11/25.
//

import UIKit
import Combine
import CoreData

/// 사용자가 '좋아요'한 비디오 목록을 표시하는 뷰 컨트롤러.
///
/// UICollectionViewDiffableDataSource를 사용하여 '좋아요' 목록을 그리드 형태로 보여주며,
/// CoreData 변경에 따라 UI를 안전하게 업데이트함.
class LikeViewController: UIViewController {

    /// '좋아요' 목록을 표시하는 컬렉션뷰. 스토리보드에 연결됨.
    @IBOutlet weak var collectionView: UICollectionView!
    /// '좋아요' 탭의 비즈니스 로직과 데이터를 관리하는 뷰모델.
    var viewModel: LikeViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Diffable Data Source에서 사용할 섹션 타입.
    enum Section {
        case main
    }

    /// 컬렉션뷰의 데이터를 관리하고 UI를 업데이트하는 Diffable Data Source.
    var dataSource: UICollectionViewDiffableDataSource<Section, Video>!

    /// 뷰가 메모리에 로드된 후 호출되는 생명주기 메서드.
    ///
    /// 데이터 소스를 설정하고, FRC의 delegate를 지정하며, 초기 UI를 로드함.
    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
        
        guard let viewModel = viewModel else { return }
        viewModel.frc.delegate = self

        updateUI(animated: false)
    }

    /// 기기 회전 등 뷰의 크기가 변경될 때 호출됨.
    ///
    /// 컬렉션뷰 레이아웃을 무효화하여 새로운 크기에 맞게 셀을 다시 계산하도록 함.
    /// - Parameters:
    ///   - size: 뷰가 전환될 새로운 크기.
    ///   - coordinator: 전환 애니메이션을 관리하는 코디네이터.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard isViewLoaded else { return }
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI(animated: false)
    }
    
    /// 컬렉션뷰에 사용할 Diffable Data Source를 생성하고 구성함.
    ///
    /// 셀을 dequeue하고, 셀의 데이터를 설정하며, 버튼 액션을 정의하는 로직을 포함함.
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section,Video>(
            collectionView: collectionView
        ) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, video: Video) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "LikeCollectionViewCell",
                for: indexPath
            ) as? LikeCollectionViewCell else {
                fatalError("Failed to dequeue LikeCollectionViewCell.")
            }
            
            cell.configure(with: video)
            
            cell.setButtonAction {
                self?.viewModel?.toggleLike(for: video)
            }
            
            return cell
        }
    }
    
    /// FRC(Fetched Results Controller)의 최신 데이터를 기반으로 UI 스냅샷을 생성하고 적용함.
    ///
    /// - Parameter animated: UI 업데이트에 애니메이션을 적용할지 여부.
    private func updateUI(animated: Bool = true) {
            guard let videos = viewModel?.frc.fetchedObjects else { return }
            
            // [추가됨] 데이터가 비어있는지 확인하고 backgroundView를 설정합니다.
            if videos.isEmpty {
                let emptyView = EmptyView()
                emptyView.configure(
                    systemName: "heart.slash",
                    title: "No liked items yet",
                    description: "Tap the like button\nto save items here"
                )
                self.collectionView.backgroundView = emptyView
            } else {
                self.collectionView.backgroundView = nil
            }
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, Video>()
            snapshot.appendSections([.main])
            snapshot.appendItems(videos, toSection: .main)
            
            dataSource.apply(snapshot, animatingDifferences: animated)
        }
}

// MARK: - UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate
/// 컬렉션뷰의 레이아웃과 데이터 변경을 처리하기 위한 델리게이트 구현.
extension LikeViewController: UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {

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
        guard let selectedVideo = dataSource.itemIdentifier(for: indexPath),
              let viewModel = self.viewModel else { return }

        let storyboard = UIStoryboard(name: "Player", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController else { return }
        
        playerVC.viewModel = PlayerViewModel(video: selectedVideo, coreDataManager: viewModel.getCoreDataManager())
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true, completion: nil)
    }
    
    /// 지정된 인덱스 경로에 있는 아이템의 크기를 계산하여 반환함.
    ///
    /// 기기 종류(아이폰/아이패드) 및 화면 방향(세로/가로)에 따라 동적으로 셀 크기를 조정함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - collectionViewLayout: 레이아웃 정보를 관리하는 객체.
    ///   - indexPath: 크기를 계산할 아이템의 인덱스 경로.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath:IndexPath
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

    /// 지정된 섹션의 콘텐츠 인셋(여백)을 결정함.
    ///
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
    ///
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
    ///
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
    
    /// FRC가 감지한 CoreData의 콘텐츠 변경이 완료되었을 때 호출됨.
    ///
    /// `updateUI`를 호출하여 컬렉션뷰를 최신 상태로 새로고침함.
    /// - Parameter controller: 콘텐츠 변경을 보고하는 FRC(Fetched Results Controller).
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateUI()
    }
}
