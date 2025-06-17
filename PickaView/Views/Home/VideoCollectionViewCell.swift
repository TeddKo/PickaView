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
        // 스켈레톤 뷰 설정
        self.isSkeletonable = true
        // contentView 설정
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

        //영상길이 레이블 커스텀
        durationLabel.layer.cornerRadius = 4
        durationLabel.layer.masksToBounds = true
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

    // MARK: - Configuration , 셀을 비디오 데이터로 구성
    func configure(with video: Video?) {
        let isSkeleton = (video == nil)

        contentView.isUserInteractionEnabled = !isSkeleton

        if isSkeleton {
            showSkeleton()
        } else {
            hideSkeleton()
            // 비디오 데이터가 있을 때만 바인딩
            bindData(video!)
        }
    }

    // Skeleton 뷰 표시
    private func showSkeleton() {
        contentView.showAnimatedGradientSkeleton()
        contentView.layoutIfNeeded()

        userNameLabel.text = nil
        viewsLabel.text = nil
        durationLabel.text = nil
        userImage.image = nil
        thumnail.image = nil
    }

    // Skeleton 뷰 숨기기
    private func hideSkeleton() {
        contentView.hideSkeleton()
    }

    //  MARK: - Data Binding , 셀에 비디오 데이터를 바인딩
    private func bindData(_ video: Video) {
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
            userImage.tintColor = UIColor(named: "MainColor")
        }

        if let thumbnailURL = video.thumbnailURL, !thumbnailURL.isEmpty {
            thumnail.loadImage(from: thumbnailURL)
        } else {
            thumnail.image = UIImage(systemName: "person.circle")
            thumnail.tintColor = UIColor(named: "MainColor")
        }

        thumnail.contentMode = .scaleAspectFill
        thumnail.clipsToBounds = true
    }
}
