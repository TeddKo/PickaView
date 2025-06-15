//
//  PlayerViewController+collectionViewUI.swift
//  PickaView
//
//  Created by 장지현 on 6/14/25.
//

import UIKit

/// PlayerViewController의 UICollectionView에 대한 UI 구성 및 레이아웃 설정을 담당
extension PlayerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 11
    }
    
    // 각 인덱스에 맞는 셀 구성: 0번은 가로 스크롤 태그 셀, 나머지는 비디오 셀
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
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
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: String(describing: PlayerViewHeaderView.self),
                for: indexPath
            ) as! PlayerViewHeaderView
            
            header.configure(views: viewModel.views, userImageURL: viewModel.userImageURL, user: viewModel.user, isLiked: viewModel.isLiked)
            return header
        }
        return UICollectionReusableView()
    }
    
    // 각 셀의 크기 계산
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            let font = UIFont.preferredFont(forTextStyle: .body)
            let text = "Sample" as NSString
            let labelHeight = text.size(withAttributes: [.font: font]).height
            
            let insets: CGFloat = 8
            
            let height = ceil(labelHeight) + (insets * 2)

            return CGSize(width: collectionView.bounds.width, height: height)
        } else {
            let width = collectionView.bounds.width
            
            var itemsPerRow: CGFloat = 1
            var insets: CGFloat = 10
            
            let isPad = traitCollection.userInterfaceIdiom == .pad
            
            if isPad {
                itemsPerRow = 2
            } else {
                itemsPerRow = 1
                insets = 0
            }
            
            let spacing: CGFloat = 10
            let totalSpacing = spacing * (itemsPerRow - 1) + insets * 2
            let itemWidth = (width - totalSpacing) / itemsPerRow
            
            return CGSize(width: itemWidth, height: (itemWidth * 9 / 16) + (itemWidth * 1 / 6) + 8)
        }
    }
    
    // 셀 간 세로 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    // 셀 간 가로 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // 디바이스 방향과 크기에 따라 섹션 여백 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        let isPhonePortrait = traitCollection.userInterfaceIdiom == .phone && width < height
        
        return isPhonePortrait ? .zero : UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}
