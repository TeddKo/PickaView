//
//  LongVideoTableViewCell.swift
//  PickaView
//
//  Created by juks86 on 6/10/25.
//

import UIKit

class LongVideoTableViewCell: UITableViewCell {


    @IBOutlet weak var longVideoThumnail: UIImageView!
//    var thumnailTapAction: (() -> Void)? //클로저로 탭 이벤트 전달

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var viewsLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.clipsToBounds = true //유저 이미지 둥글게 설정
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
