//
//  PlayerViewController+collectionViewUI.swift
//  PickaView
//
//  Created by 장지현 on 6/14/25.
//

import UIKit

/// PlayerViewController의 UICollectionView에 대한 UI 구성 및 레이아웃 설정을 담당
extension PlayerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 11
    }
    
    // 각 인덱스에 맞는 셀 구성: 0번은 가로 스크롤 태그 셀, 나머지는 비디오 셀
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let viewModel else { fatalError("viewModel nil") }
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: HorizontalCollectionViewCell.self),
                for: indexPath
            ) as! HorizontalCollectionViewCell
            
            cell.tags = viewModel.tags
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: PlayerViewCollectionViewCell.self),
                for: indexPath
            ) as! PlayerViewCollectionViewCell
            
            let video = viewModel.videos[indexPath.item - 1]
            
            cell.configure(with: video)
            return cell
        }
    }
    
    // 섹션 헤더 뷰의 크기 설정 (사용자 정보 + 좋아요 등)
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let width = collectionView.bounds.width
        
        let font = UIFont.preferredFont(forTextStyle: .footnote)
        let text = "Sample" as NSString
        let labelHeight = text.size(withAttributes: [.font: font]).height
        
        let stackInsets: CGFloat = 16
        let imageInsets: CGFloat = 10
        var imageHeight: CGFloat = width / 6
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            imageHeight = width / 12
        }
        
        let height = stackInsets + ceil(labelHeight) + (imageInsets * 2) + imageHeight
        
        return CGSize(width: collectionView.bounds.width, height: height)
    }
    
    // 섹션 헤더 뷰를 생성 및 설정
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let viewModel else { fatalError("viewModel nil") }
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: String(describing: PlayerViewHeaderView.self),
                for: indexPath
            ) as! PlayerViewHeaderView
            
            header.onLikeButtonTapped = { [weak self] in
                guard let self, let viewModel = self.viewModel else {
                    fatalError("PlayerViewController has been deallocated before like button tapped.")
                }
                return viewModel.toggleLikeStatus()
            }
            
            header.configure(views: viewModel.views, userImageURL: viewModel.userImageURL, user: viewModel.user, isLiked: viewModel.isLiked)
            
            return header
        }
        return UICollectionReusableView()
    }
    
    // 각 셀의 크기 계산
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // 0번 인덱스는 태그 셀이므로 기존 로직을 유지합니다.
        if indexPath.item == 0 {
            let font = UIFont.preferredFont(forTextStyle: .body)
            let text = "Sample" as NSString
            let labelHeight = text.size(withAttributes: [.font: font]).height
            
            let insets: CGFloat = 8
            let height = ceil(labelHeight) + (insets * 2)

            return CGSize(width: collectionView.bounds.width, height: height)
        } else {
            return calculateVideoCellSize(
                for: collectionView,
                layout: collectionViewLayout,
                at: indexPath
            )
        }
    }
    
    // 셀 간 세로 간격 설정
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 30
    }
    
    // 셀 간 가로 간격 설정
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10
    }
    
    // 디바이스 방향과 크기에 따라 섹션 여백 설정
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        let isPhonePortrait = traitCollection.userInterfaceIdiom == .phone && width < height
        
        return isPhonePortrait ? .zero : .init(horizontal: 10)
    }
    
    // 셀 선택 시 동작 처리
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 0번째는 태그 셀이므로 무시
        guard let viewModel else { return }
        guard indexPath.item > 0 else { return }

        let selectedVideo = viewModel.videos[indexPath.item - 1]
        replaceWithNewVideo(selectedVideo)
    }
    
    /// 현재 플레이어 화면을 닫고, 선택한 비디오로 새로운 PlayerViewController를 모달로 띄웁니다.
    /// - Parameter video: 새로 재생할 비디오 객체
    func replaceWithNewVideo(_ video: Video) {
        guard let presentingVC = self.presentingViewController else { return }

        // 현재 플레이어 화면을 닫은 뒤, 새 비디오로 다시 화면을 구성
        self.dismiss(animated: false) { [weak self] in
            guard let self, let viewModel = self.viewModel else { return }
            
            let storyboard = UIStoryboard(name: "Player", bundle: nil)
            guard let newPlayerVC = storyboard.instantiateViewController(
                withIdentifier: String(
                    describing: PlayerViewController.self
                )
            ) as? PlayerViewController else { return }
            newPlayerVC.modalPresentationStyle = .fullScreen
            
            let newPlayerVM = PlayerViewModel(
                video: video,
                coreDataManager: viewModel.getCoreDataManager()
            )
            newPlayerVC.viewModel = newPlayerVM

            presentingVC.present(newPlayerVC, animated: false)
        }
    }
    
    private func calculateVideoCellSize(
        for collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        at indexPath: IndexPath
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
            
            let itemsPerRow: CGFloat = isPad ? 2 : 1
            
            let totalHorizontalSpacing = insets.left + insets.right + (interitemSpacing * (itemsPerRow - 1))
            
            let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / itemsPerRow
            
            let thumbnailHeight = itemWidth * 9 / 16
            let userInfoHeight = itemWidth * 1 / 6
            let itemHeight = thumbnailHeight + userInfoHeight + 8
            
            return CGSize(width: itemWidth, height: itemHeight)
        }
}
