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

    @IBAction func likeButton(_ sender: Any) {
    }
    
    @IBOutlet weak var likeButton: UIButton!

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
}
