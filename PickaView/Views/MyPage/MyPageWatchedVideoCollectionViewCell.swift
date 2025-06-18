//
//  MyPageWatchedVideoCollectionViewCell.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/10/25.
//

import UIKit

/// 마이페이지의 '최근 시청 영상' 목록에 표시되는 개별 비디오 셀.
///
/// 내부에 `MediaContentView`를 포함하여 썸네일과 영상 길이를 표시함.
class MyPageWatchedVideoCollectionViewCell: UICollectionViewCell {
    
    /// 셀을 식별하고 재사용하기 위한 정적 식별자.
    static let identifier = "WatchedVideoCell"
    
    /// 셀의 UI를 구성하는 커스텀 뷰.
    private let mediaContentView = MediaContentView()
    
    /// 코드로 셀을 초기화함.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    /// Interface Builder(스토리보드)에서 셀을 초기화하는 것은 지원하지 않음.
    ///
    /// 스토리보드에서 사용 시 `fatalError`를 발생시킴.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
        fatalError("init(coder:) has not been implemented")
    }
    
    /// `mediaContentView`를 셀의 `contentView`에 추가하고 레이아웃 및 UI 속성을 설정함.
    private func setupCell() {
        contentView.addSubview(mediaContentView)
        mediaContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mediaContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mediaContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    /// `Video` 객체의 데이터로 셀의 UI를 구성함.
    ///
    /// `mediaContentView`에 썸네일 URL과 영상 길이를 전달함.
    /// - Parameter video: 셀에 표시할 `Video` 객체.
    public func configure(with video: Video) {
        guard let timestamp = video.timeStamp else { return }
        
        mediaContentView.configure(
            thumbnailURL: video.thumbnailURL ?? "",
            videoLength: timestamp.totalTime
        )
    }
}
