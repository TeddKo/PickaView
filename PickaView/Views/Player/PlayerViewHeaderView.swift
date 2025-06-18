//
//  PlayerViewHeaderView.swift
//  PickaView
//
//  Created by 장지현 on 6/14/25.
//

import UIKit

/// 플레이어 화면 상단에 표시되는 헤더 뷰
/// 업로더 프로필 이미지, 업로더 이름, 조회수, 좋아요 버튼
class PlayerViewHeaderView: UICollectionReusableView {
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    // Like 버튼 클릭 시 실행될 클로저
    var onLikeButtonTapped: (() -> Bool)?

    @IBAction func like(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()

        let isCurrentlyLiked = onLikeButtonTapped?()
        likeButton.tintColor = isCurrentlyLiked ?? false ? .main : .systemGray4

        UIView.animate(withDuration: 0.1,
                       animations: {
                           self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.1) {
                               self.likeButton.transform = CGAffineTransform.identity
                           }
                       })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // 기존 제약 제거
            let allConstraints = self.constraints + userImageView.constraints
            if let constraintToRemove = allConstraints.first(where: {
                $0.firstItem === userImageView &&
                $0.secondItem === self &&
                $0.firstAttribute == .height &&
                $0.secondAttribute == .width &&
                abs($0.multiplier - (1.0 / 6.0)) < 0.0001
            }) {
                constraintToRemove.isActive = false
                self.removeConstraint(constraintToRemove)
            }

            // 새 제약 추가
            let heightConstraint = userImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0 / 12.0)
            heightConstraint.priority = .required
            heightConstraint.isActive = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 업로더 이미지 뷰를 원형으로 설정
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
    }
    
    /// 헤더 뷰에 데이터를 설정
    /// - Parameters:
    ///   - views: 조회수 텍스트
    ///   - userImageURL: 업로더 이미지 URL (옵션)
    ///   - user: 업로더 이름
    ///   - isLiked: 좋아요 상태
    func configure(views: String, userImageURL: String?, user: String, isLiked: Bool) {
        viewsLabel.text = views
        if let userImageURL = userImageURL, !userImageURL.isEmpty {
            userImageView.loadImage(from: userImageURL)
        } else {
            userImageView.image = UIImage(systemName: "person.circle")
        }
        usernameLabel.text = user
        likeButton.tintColor = isLiked ? .main : .systemGray4
    }
}
