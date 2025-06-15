//
//  HorizontalCollectionViewCell.swift
//  PickaView
//
//  Created by 장지현 on 6/14/25.
//

import UIKit

/// 수평 스크롤 태그 목록을 표시하는 셀
/// 내부에 UICollectionView를 포함, 태그 데이터를 기반으로 셀을 구성
class HorizontalCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    // 표시할 태그 목록 데이터
    var tags: [Tag] = []
    
    // 태그들을 표시할 내부 컬렉션 뷰
    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    // 태그의 개수를 셀 개수로 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    // 인덱스에 해당하는 태그 셀 구성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TagCollectionViewCell.self), for: indexPath) as! TagCollectionViewCell
        
        cell.configure(tag: tags[indexPath.item])
        return cell
    }
}

/// 개별 태그 항목을 표현하는 셀
/// 배경 색상, 테두리, 코너 반경 등의 UI를 설정하고 태그 이름을 표시
class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tagBackgroundView: UIView!
    @IBOutlet weak var tagNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagBackgroundView.backgroundColor = .tagBackground
        tagBackgroundView.layer.borderColor = UIColor(named: "SubColor")?.cgColor
        
        tagBackgroundView.layer.borderWidth = 1.0
        tagBackgroundView.layer.cornerRadius = 18
        tagBackgroundView.clipsToBounds = true
    }
    
    // 태그 정보를 셀에 설정
    func configure(tag: Tag) {
        tagNameLabel.text = tag.name
    }
}
