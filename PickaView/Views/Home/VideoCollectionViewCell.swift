//
//  VideoCollectionViewCell.swift
//  PickaView
//
//  Created by juks86 on 6/11/25.
//

import UIKit
import SkeletonView

class VideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thumnail: UIImageView!

    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var userImage: UIImageView!

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var viewsLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true       // 셀 자체에 추가
        contentView.isSkeletonable = true

        [thumnail, userImage, userNameLabel, viewsLabel, durationLabel].forEach {
            $0?.isSkeletonable = true
            contentView.backgroundColor = .clear
        }
        contentView.isSkeletonable = true
        contentView.backgroundColor = .clear

        //유저 이미지 둥글게 처리
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.clipsToBounds = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        // 재사용 시 스켈레톤 제거
        contentView.hideSkeleton()

        // 이전 내용 초기화 (재사용 오류 방지)
        thumnail.image = nil
        userImage.image = nil
        userNameLabel.text = nil
        viewsLabel.text = nil
        durationLabel.text = nil
    }

    func configure(with video: Video?) {
        if let video = video {
            // 데이터가 있을 때는 스켈레톤 숨기고, 데이터 바인딩
            contentView.hideSkeleton()
            contentView.isUserInteractionEnabled = true

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
            thumnail.clipsToBounds = true

        } else {
            // 데이터가 없으면 애니메이션 스켈레톤 보여주기
            contentView.isUserInteractionEnabled = false

            let gradient = SkeletonGradient(
                baseColor: UIColor(red: 0.8, green: 0.8, blue: 0.85, alpha: 1),
                secondaryColor: UIColor(red: 0.65, green: 0.65, blue: 0.7, alpha: 1)
            )
            let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)

            contentView.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
            contentView.layoutIfNeeded()

            // 데이터 초기화
            userNameLabel.text = nil
            viewsLabel.text = nil
            durationLabel.text = nil
            userImage.image = nil
            thumnail.image = nil
        }
    }

}
