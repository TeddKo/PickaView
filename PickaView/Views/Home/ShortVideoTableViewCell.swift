//
//  ShortVideoTableViewCell.swift
//  PickaView
//
//  Created by juks86 on 6/10/25.
//

import UIKit

class ShortVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    let shortVideoImages: [UIImage] = [
           UIImage(named: "short1")!,
           UIImage(named: "short2")!,
           UIImage(named: "short3")!,
           UIImage(named: "short4")!,
           UIImage(named: "short5")!
       ]

    override func awakeFromNib() {
           super.awakeFromNib()

           collectionView.dataSource = self
           collectionView.delegate = self

           // CollectionView Cell 등록
           collectionView.register(UINib(nibName: "ShortVideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShortVideoCollectionViewCell")

           // 가로 스크롤 설정
           if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
               flowLayout.scrollDirection = .horizontal
           }
       }
   }

   extension ShortVideoTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return shortVideoImages.count
       }

       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShortVideoCollectionViewCell", for: indexPath) as! ShortVideoCollectionViewCell
           cell.thumnailImage.image = shortVideoImages[indexPath.item]
           return cell
       }

       // 셀 크기 설정
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: 120, height: collectionView.frame.height)
       }
   }
