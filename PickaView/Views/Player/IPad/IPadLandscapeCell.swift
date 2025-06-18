//
//  IPadLandscapeCell.swift
//  PickaView
//
//  Created by 장지현 on 6/17/25.
//

import UIKit

class IPadLandscapeCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        thumbnailImageView.layer.cornerRadius = 5
        
        durationView.layer.cornerRadius = 4
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
    }
    
    func configure(with video: Video) {
        // 썸네일 이미지 설정, 없으면 기본 이미지 사용
        if let thumbnailURL = video.thumbnailURL, !thumbnailURL.isEmpty {
            thumbnailImageView.loadImage(from: thumbnailURL)
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        }
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        
        // 사용자 이미지 설정, 없으면 기본 이미지 사용
        if let userImageURL = video.userImageURL, !userImageURL.isEmpty {
            userImageView.loadImage(from: userImageURL)
        } else {
            userImageView.image = UIImage(systemName: "person.circle")
        }
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        
        usernameLabel.text = video.user
        viewsLabel.text = video.views.formattedViews()
        
        // 총 재생 시간을 포맷팅하여 표시
        if let durationSeconds = video.timeStamp?.totalTime {
            durationLabel.text = Int(durationSeconds).toDurationString()
        } else {
            durationLabel.text = "Duration: N/A"
        }
    }
}
