//
//  Extension.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/11/25.
//

import UIKit

extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL string.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Error: No data or could not create image.")
                return
            }
            DispatchQueue.main.async {
                self.image = image
            }
        }
        task.resume()
    }
}


extension UIView {
    /// 특정 방향의 여백을 채우기 위한 UIView의 확장 래퍼함수.
    /// - Parameters:
    ///   - stackView: container와 view를 담을 스택.
    ///   - topPadding: 위쪽 방향에 적용할 여백.
    ///   - leftPadding: 왼쪽 방향에 적용할 여백.
    ///   - rightPadding: 오른쪽 방향에 적용할 여백.
    ///   - bottomPadding: 아래쪽 방향에 적용할 여백.
    func wrappedPaddingContainer(
        stackView: UIStackView,
        topPadding: CGFloat? = nil,
        leftPadding: CGFloat? = nil,
        rightPadding: CGFloat? = nil,
        bottomPadding: CGFloat? = nil
    ) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(containerView)
        containerView.addSubview(self)
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topPadding ?? 0),
            self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leftPadding ?? 0),
            self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -(rightPadding ?? 0)),
            self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(bottomPadding ?? 0)),
        ])
    }
    
    /// 모든방향의 여백을 채우기 위한 UIView의 확장 래퍼함수.
    /// - Parameters:
    ///   - stackView: container와 view를 담을 스택.
    ///   - allPadding: 모든 방향에 적용할 여백.
    func wrappedPaddingContainer(
        stackView: UIStackView,
        allPadding: CGFloat
    ) {
        return wrappedPaddingContainer(
            stackView: stackView,
            topPadding: allPadding,
            leftPadding: allPadding,
            rightPadding: allPadding,
            bottomPadding: allPadding
        )
    }

    
    /// 가로방향의 여백을 채우기 위한 UIView의 확장 래퍼함수.
    /// - Parameters:
    ///   - stackView: container와 view를 담을 스택.
    ///   - horizontalPadding: 가로방향에 적용할 여백.
    func wrappedPaddingContainer(
        stackView: UIStackView,
        horizontalPadding: CGFloat
    ) {
        return wrappedPaddingContainer(
            stackView: stackView,
            topPadding: 0,
            leftPadding: horizontalPadding,
            rightPadding: horizontalPadding,
            bottomPadding: 0
        )
    }

    
    /// 세로방향의 여백을 채우기 위한 UIView의 확장 래퍼함수.
    /// - Parameters:
    ///   - stackView: container와 view를 담을 스택.
    ///   - verticalPadding: 세로방향에 적용할 여백.
    func wrappedPaddingContainer(
        stackView: UIStackView,
        verticalPadding: CGFloat
    ) {
        return wrappedPaddingContainer(
            stackView: stackView,
            topPadding: verticalPadding,
            leftPadding: 0,
            rightPadding: 0,
            bottomPadding: verticalPadding
        )
    }
}
