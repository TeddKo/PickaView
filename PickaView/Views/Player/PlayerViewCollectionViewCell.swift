//
//  PlayerViewCollectionViewCell.swift
//  PickaView
//
//  Created by 장지현 on 6/14/25.
//

import UIKit

/// 추천 영상 목록에서 개별 비디오를 나타내는 컬렉션 뷰 셀
/// 썸네일, 영상 길이, 업로더 정보(이미지, 이름), 조회수를 표시
class PlayerViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        durationView.layer.cornerRadius = 4
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
    }
    
    /// 비디오 정보를 기반으로 셀 UI 구성
    /// - Parameter video: 표시할 비디오 데이터
    func configure(with video: Video) {
        usernameLabel.text = video.user
        viewsLabel.text = "Views: \(video.views)"
        
        // 총 재생 시간을 포맷팅하여 표시
        if let durationSeconds = video.timeStamp?.totalTime {
            durationLabel.text = Int(durationSeconds).toDurationString()
        } else {
            durationLabel.text = "Duration: N/A"
        }
        
        // 사용자 이미지 설정, 없으면 기본 이미지 사용
        if let userImageURL = video.userImageURL, !userImageURL.isEmpty {
            userImageView.loadImage(from: userImageURL)
        } else {
            userImageView.image = UIImage(systemName: "person.circle")
        }
        
        // 썸네일 이미지 설정, 없으면 기본 이미지 사용
        if let thumbnailURL = video.thumbnailURL, !thumbnailURL.isEmpty {
            thumbnailImageView.loadImage(from: thumbnailURL)
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        }
        
        thumbnailImageView.contentMode = .scaleAspectFill
    }
}
