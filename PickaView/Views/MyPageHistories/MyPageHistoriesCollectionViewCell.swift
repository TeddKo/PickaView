//
//  MyPageHistoriesCollectionViewCell.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/16/25.
//

import UIKit

/// '시청 기록 전체 보기' 화면에 표시되는 개별 비디오 셀.
///
/// 내부에 `MediaHistoryCellView`를 포함하여 실제 UI를 구성함.
class MyPageHistoriesCollectionViewCell: UICollectionViewCell {
    
    /// 셀의 UI를 구성하는 커스텀 뷰.
    let mediaHistoryCellView = MediaHistoryCellView()
    
    /// Interface Builder로부터 셀이 로드될 때 호출됨.
    ///
    /// 초기 UI 설정을 위해 `setupCell`을 호출함.
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    /// `mediaHistoryCellView`를 셀의 `contentView`에 추가하고 제약조건을 설정함.
    private func setupCell() {
        
        mediaHistoryCellView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mediaHistoryCellView)
        
        NSLayoutConstraint.activate([
            mediaHistoryCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaHistoryCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaHistoryCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mediaHistoryCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    /// `Video` 객체의 데이터로 셀의 UI를 구성함.
    /// - Parameter video: 셀에 표시할 `Video` 객체.
    func configure(with video: Video) {
        guard let timestamp = video.timeStamp, let date = timestamp.startDate, let tags = video.tags as? Set<Tag>, let thumbnailURL = video.thumbnailURL else { return }
        mediaHistoryCellView
            .configure(
                date: date,
                thumbnailURL: thumbnailURL,
                videoLength: timestamp.totalTime,
                tags: tags
            )
    }
    
    /// 셀이 재사용되기 직전에 호출됨.
    ///
    /// `mediaHistoryCellView`의 콘텐츠를 초기화하여 재사용 시 발생할 수 있는 UI 오류를 방지함.
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mediaHistoryCellView.resetContents()
    }
}
