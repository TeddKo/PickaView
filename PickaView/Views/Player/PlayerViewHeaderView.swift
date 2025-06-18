//
//  PlayerViewHeaderView.swift
//  PickaView
//
//  Created by 장지현 on 6/14/25.
//

import UIKit

/// 플레이어 화면 상단에 표시되는 헤더 뷰
///
/// 업로더의 프로필 이미지, 이름, 조회수, 좋아요 버튼 등을 포함
/// 아이패드 환경에서는 사용자 이미지 뷰의 제약을 동적으로 조정
class PlayerViewHeaderView: UICollectionReusableView {
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    /// 좋아요 버튼이 탭되었을 때 실행되는 클로저
    ///
    /// 클로저의 반환값은 현재 좋아요 상태를 나타내며, 버튼 색상에 반영
    var onLikeButtonTapped: (() -> Bool)?

    /// 좋아요 버튼 탭 시 호출되는 액션 메서드
    ///
    /// 햅틱 피드백을 발생시키고, 버튼 색상과 크기를 애니메이션으로 변경
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
    
    /// 뷰가 초기화될 때 호출
    ///
    /// 아이패드 환경에서 사용자 이미지의 높이 제약을 1/12로 재조정
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
    
    /// 업로더 프로필 이미지를 원형으로 설정
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
    }
    
    /// 헤더 뷰에 필요한 데이터를 설정
    ///
    /// - Parameters:
    ///   - views: 조회수 문자열
    ///   - userImageURL: 업로더 프로필 이미지의 URL
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
