//
//  HorizontalCollectionViewCell.swift
//  PickaView
//
//  Created by 장지현 on 6/14/25.
//

import UIKit

/// 수평 스크롤 태그 목록을 표시하는 셀
///
/// 'UICollectionView'를 포함하고 있으며, 각 셀은 태그 정보를 표시
/// 'UICollectionViewDataSource', 'UICollectionViewDelegate'를 구현하여 셀 구성 및 동작을 제어
class HorizontalCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    var tags: [Tag] = []
    @IBOutlet weak var tagCollectionView: UICollectionView!
    
    /// 컬렉션 뷰의 항목 수를 반환
    ///
    /// - Parameters:
    ///   - collectionView: 태그를 표시할 컬렉션 뷰
    ///   - section: 섹션 인덱스
    /// - Returns: 태그 개수만큼의 셀 수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    /// 주어진 위치에 해당하는 태그 셀을 반환
    ///
    /// - Parameters:
    ///   - collectionView: 태그를 표시할 컬렉션 뷰
    ///   - indexPath: 셀의 위치를 나타내는 인덱스 경로
    /// - Returns: 구성된 태그 셀
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TagCollectionViewCell.self), for: indexPath) as! TagCollectionViewCell
        
        cell.configure(tag: tags[indexPath.item])
        return cell
    }
}

/// 개별 태그 항목을 표현하는 셀
///
/// 태그 이름을 라벨로 표시하고, 배경 뷰에는 색상, 테두리, 코너 반경 등의 UI 속성을 설정
class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tagBackgroundView: UIView!
    @IBOutlet weak var tagNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tagBackgroundView.backgroundColor = .tagBackground
        tagBackgroundView.layer.borderColor = UIColor(named: "SubColor")?.cgColor
        
        tagBackgroundView.layer.borderWidth = 1.0
        tagBackgroundView.layer.cornerRadius = 17
        tagBackgroundView.clipsToBounds = true
    }
    
    /// 주어진 태그를 기반으로 셀을 구성
    ///
    /// - Parameter tag: 셀에 표시할 태그 객체
    func configure(tag: Tag) {
        tagNameLabel.text = tag.name
    }
}
