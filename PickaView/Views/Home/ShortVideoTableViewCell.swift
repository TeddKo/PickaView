//
//  ShortVideoTableViewCell.swift
//  PickaView
//
//  Created by juks86 on 6/10/25.
//

import UIKit

class ShortVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    let symbolData: [(user: String, symbolName: String)] = [
           ("Alice", "video.fill"),
           ("Bob", "video.circle.fill"),
           ("Charlie", "play.rectangle.fill"),
           ("David", "film.fill")
       ]

       override func awakeFromNib() {
           super.awakeFromNib()

           collectionView.dataSource = self
           collectionView.delegate = self

       }
   }

   extension ShortVideoTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return symbolData.count
       }

       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShortVideoCollectionViewCell", for: indexPath) as! ShortVideoCollectionViewCell
           let item = symbolData[indexPath.item]
           cell.userNameLabel.text = item.user
           cell.thumnailImage.image = UIImage(systemName: item.symbolName)
           cell.thumnailImage.tintColor = .systemBlue
           return cell
       }
   }
