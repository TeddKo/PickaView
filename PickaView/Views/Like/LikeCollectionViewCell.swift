//
//  LikeCollectionViewCell.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/12/25.
//

import UIKit

class LikeCollectionViewCell: UICollectionViewCell {
    
    let likeCellView = LikeCellView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        
        likeCellView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(likeCellView)
        
        NSLayoutConstraint.activate([
            likeCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            likeCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            likeCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            likeCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(like: DummyLike) {
        likeCellView
            .configure(
                date: like.date,
                thumbnailURL: like.thumbnailURL,
                videoLength: like.videoLength,
                tags: like.tags
            )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        likeCellView.resetContents()
    }
}


struct DummyLike {
    let date: Date
    let thumbnailURL: String
    let videoLength: Double
    let tags: [String]
}
