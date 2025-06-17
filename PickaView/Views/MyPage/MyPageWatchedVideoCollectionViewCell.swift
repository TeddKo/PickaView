//
//  RandomColorCollectionViewCell.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/10/25.
//

import UIKit

class MyPageWatchedVideoCollectionViewCell: UICollectionViewCell {
    static let identifier = "WatchedVideoCell"
    
    private let mediaContentView = MediaContentView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(mediaContentView)
        mediaContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mediaContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mediaContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // 셀의 모서리를 둥글게
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    // ViewController에서 이 함수를 호출하여 셀의 색상을 설정
    public func configure(with video: Video) {
        guard let timestamp = video.timeStamp else { return }
        
        print("thumbnailURL: \(video.thumbnailURL ?? "")")
        
        mediaContentView.configure(
            thumbnailURL: video.thumbnailURL ?? "",
            videoLength: timestamp.totalTime
        )
    }
}
