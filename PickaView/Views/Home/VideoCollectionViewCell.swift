//
//  VideoCollectionViewCell.swift
//  PickaView
//
//  Created by juks86 on 6/11/25.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumnail: UIImageView!

    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var userImage: UIImageView!

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var viewsLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()

        //유저 이미지 둥글게 처리
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()

        // 이전 내용 초기화 (재사용 오류 방지)
        thumnail.image = nil
        userImage.image = nil
        userNameLabel.text = nil
        viewsLabel.text = nil
        durationLabel.text = nil
    }

    func configure(with video: Video) {
        userNameLabel.text = video.user
        viewsLabel.text = "Views: \(video.views)"

        if let durationSeconds = video.timeStamp?.totalTime {
            durationLabel.text = Int(durationSeconds).toDurationString()
        } else {
            durationLabel.text = "Duration: N/A"
        }

        if let userImageURL = video.userImageURL, !userImageURL.isEmpty {
            userImage.loadImage(from: userImageURL)
        } else {
            userImage.image = UIImage(systemName: "person.circle")
        }

        if let thumbnailURL = video.thumbnailURL, !thumbnailURL.isEmpty {
            thumnail.loadImage(from: thumbnailURL)
        } else {
            thumnail.image = UIImage(systemName: "person.circle")
        }

        thumnail.contentMode = .scaleAspectFill
        thumnail.clipsToBounds = true // 이미지 넘침 방지
    }

}
