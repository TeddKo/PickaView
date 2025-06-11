//
//  Components.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/11/25.
//

import UIKit

/**
 주어진 뷰를 컨테이너 뷰로 감싸 좌우 여백을 적용하고 `mainVerticalStackView`에 추가하는 래퍼(Wrapper) 함수.
 - Parameters:
 - view: 여백을 적용할 대상 뷰.
 - leftPadding: 왼쪽에 적용할 여백 크기.
 - rightPadding: 오른쪽에 적용할 여백 크기.
 **/
func wrappedPaddingContainer(
    stackView: UIStackView,
    view: UIView,
    leftPadding: CGFloat,
    rightPadding: CGFloat
) {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    stackView.addArrangedSubview(containerView)
    containerView.addSubview(view)
    
    // 제약조건 설정. `trailingAnchor`의 constant는 음수 값을 사용해야 함.
    NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: containerView.topAnchor),
        view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leftPadding),
        view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -rightPadding),
        view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    ])
}
