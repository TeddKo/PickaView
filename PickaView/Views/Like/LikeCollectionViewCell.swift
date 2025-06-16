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
    
    func configure(with video: Video) {
        guard let timestamp = video.timeStamp, let tags = video.tags as? Set<Tag>, let thumbnailURL = video.thumbnailURL else { return }
        likeCellView
            .configure(
                thumbnailURL: thumbnailURL,
                videoLength: timestamp.totalTime,
                tags: tags
            )
    }
    
    func setButtonAction(action: @escaping () -> Void) {
        likeCellView.setButtonAction(action: action)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        likeCellView.resetContents()
    }
}
