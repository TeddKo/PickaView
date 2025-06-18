//
//  LikeCollectionViewCell.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/12/25.
//

import UIKit

/// '좋아요' 목록에 표시되는 개별 비디오 셀.
///
/// 내부에 `LikeCellView`를 포함하여 실제 UI를 구성함.
class LikeCollectionViewCell: UICollectionViewCell {
    
    /// 셀의 UI를 구성하는 커스텀 뷰.
    let likeCellView = LikeCellView()
    
    /// Interface Builder로부터 셀이 로드될 때 호출됨.
    ///
    /// 초기 UI 설정을 위해 `setupCell`을 호출함.
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    /// `likeCellView`를 셀의 `contentView`에 추가하고 제약조건을 설정함.
    private func setupCell() {
        
        likeCellView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(likeCellView)
        
        NSLayoutConstraint.activate([
            likeCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            likeCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            likeCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            likeCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    /// `Video` 객체의 데이터로 셀의 UI를 구성함.
    /// - Parameter video: 셀에 표시할 `Video` 객체.
    func configure(with video: Video) {
        guard let timestamp = video.timeStamp, let tags = video.tags as? Set<Tag>, let thumbnailURL = video.thumbnailURL else { return }
        likeCellView
            .configure(
                thumbnailURL: thumbnailURL,
                videoLength: timestamp.totalTime,
                tags: tags,
                isLiked: video.isLiked
            )
    }
    
    /// 셀 내부의 '좋아요' 버튼이 탭되었을 때 실행될 클로저를 설정함.
    /// - Parameter action: 버튼 탭 시 실행될 클로저.
    func setButtonAction(action: @escaping () -> Bool) {
        likeCellView.setButtonAction(action: action)
    }
    
    /// 셀이 재사용되기 직전에 호출됨.
    ///
    /// `likeCellView`의 콘텐츠를 초기화하여 재사용 시 발생할 수 있는 UI 오류를 방지함.
    override func prepareForReuse() {
        super.prepareForReuse()
        
        likeCellView.resetContents()
    }
}
