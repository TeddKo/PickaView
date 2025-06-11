//
//  PlayerViewController+UI.swift
//  PickaView
//
//  Created by junil on 6/10/25.
//

import UIKit

extension PlayerViewController {

    /// SF Symbol 이름과 크기를 받아 버튼을 생성
    ///
    /// - Parameters:
    ///   - systemName: SF Symbol 이름
    ///   - pointSize: 아이콘 크기(기본값 30)
    /// - Returns: 구성된 UIButton
    func createButton(systemName: String, pointSize: CGFloat = 30) -> UIButton {
        var config = UIButton.Configuration.plain()
        let image = UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: .light))
        config.image = image
        config.baseForegroundColor = .white
        config.background.backgroundColor = .clear
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    /// 시간 표시용 레이블을 만듬
    ///
    /// - Parameter text: 표시할 텍스트
    /// - Returns: 구성된 UILabel (흰색, 모노스페이스 폰트)
    func createTimeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// 스크롤뷰에 더미(placeholder) 콘텐츠를 추가
    ///
    /// - Note: 데모/프로토타입 용도로 빨간색 뷰를 여러 개 추가
    func addDummyContentToScrollView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for _ in 1...5 {
            let dummyView = UIView()
            dummyView.backgroundColor = .red.withAlphaComponent(0.6)
            dummyView.layer.cornerRadius = 15
            dummyView.heightAnchor.constraint(equalToConstant: 220).isActive = true
            stackView.addArrangedSubview(dummyView)
        }

        contentScrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentScrollView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor, constant: -15),
            stackView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, constant: -30)
        ])
    }
}
