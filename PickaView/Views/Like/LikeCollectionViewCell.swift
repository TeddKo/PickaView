//
//  LikeCollectionViewCell.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/12/25.
//

import UIKit

class LikeCollectionViewCell: UICollectionViewCell {
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setupCell() {
        let likeCellView = LikeCellView()
        
        likeCellView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            likeCellView.topAnchor.constraint(equalTo: topAnchor),
            likeCellView.leadingAnchor.constraint(equalTo: leadingAnchor),
            likeCellView.trailingAnchor.constraint(equalTo: trailingAnchor),
            likeCellView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
