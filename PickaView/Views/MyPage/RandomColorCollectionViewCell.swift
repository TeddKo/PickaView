//
//  RandomColorCollectionViewCell.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/10/25.
//

import UIKit

class RandomColorCollectionViewCell: UICollectionViewCell {
    static let identifier = "RandomColorCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    private func setupCell() {
        // 셀의 모서리를 둥글게
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    // ViewController에서 이 함수를 호출하여 셀의 색상을 설정
    public func configure(with color: UIColor) {
        contentView.backgroundColor = color
    }
}
