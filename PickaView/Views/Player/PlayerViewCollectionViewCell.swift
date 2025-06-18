//
//  PlayerViewCollectionViewCell.swift
//  PickaView
//
//  Created by 장지현 on 6/14/25.
//

import UIKit

/// 추천 영상 목록에서 개별 비디오 정보를 표시하는 셀
///
/// 썸네일 이미지, 영상 길이, 업로더 프로필 이미지 및 이름, 조회 수 등을 포함한 UI 요소로 구성
class PlayerViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    
    /// 셀의 하위 뷰들의 레이아웃을 조정.
    ///
    /// durationView의 코너 반경과, userImageView의 원형 마스크 처리를 수행
    override func layoutSubviews() {
        super.layoutSubviews()
        
        durationView.layer.cornerRadius = 4
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
    }
    
    /// 비디오 정보를 기반으로 셀의 UI 요소를 구성
    ///
    /// - Parameter video: 셀에 표시할 'Video' 객체
    func configure(with video: Video) {
        usernameLabel.text = video.user
        viewsLabel.text = video.views.formattedViews()
        
        if let durationSeconds = video.timeStamp?.totalTime {
            durationLabel.text = Int(durationSeconds).toDurationString()
        } else {
            durationLabel.text = "Duration: N/A"
        }
        
        if let userImageURL = video.userImageURL, !userImageURL.isEmpty {
            userImageView.loadImage(from: userImageURL)
        } else {
            userImageView.image = UIImage(systemName: "person.circle")
        }
        
        if let thumbnailURL = video.thumbnailURL, !thumbnailURL.isEmpty {
            thumbnailImageView.loadImage(from: thumbnailURL)
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        }
        
        thumbnailImageView.contentMode = .scaleAspectFill
    }
}
