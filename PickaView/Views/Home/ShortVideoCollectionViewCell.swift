//
//  ShortVideoCollectionViewCell.swift
//  PickaView
//
//  Created by juks86 on 6/10/25.
//

import UIKit

class ShortVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var thumnailImage: UIImageView!

    override func awakeFromNib() {
         super.awakeFromNib()
         thumnailImage.contentMode = .scaleAspectFit
         thumnailImage.tintColor = .systemBlue // SF Symbol 색상
     }
 }
