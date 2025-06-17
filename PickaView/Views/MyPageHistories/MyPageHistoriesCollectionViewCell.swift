//
//  MypageHistoriesCollectionViewCell.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/16/25.
//

import UIKit

class MyPageHistoriesCollectionViewCell: UICollectionViewCell {
    
    let mediaHistoryCellView = MediaHistoryCellView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    private func setupCell() {
        
        mediaHistoryCellView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mediaHistoryCellView)
        
        NSLayoutConstraint.activate([
            mediaHistoryCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaHistoryCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaHistoryCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mediaHistoryCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(width video: Video) {
        guard let timestamp = video.timeStamp, let date = timestamp.startDate, let tags = video.tags as? Set<Tag>, let thumbnailURL = video.thumbnailURL  else { return }
        mediaHistoryCellView
            .configure(
                date: date,
                thumbnailURL: thumbnailURL,
                videoLength: timestamp.totalTime,
                tags: tags
            )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mediaHistoryCellView.resetContents()
    }
}
