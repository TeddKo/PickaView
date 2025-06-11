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
    /**
     주어진 뷰를 컨테이너 뷰로 감싸 좌우 여백을 적용하고 `stackView`에 추가하는 래퍼(Wrapper) 함수.
     - Parameters:
     - stackView: container와 view를 담을 스택.
     - view: 여백을 적용할 대상 뷰.
     - leftPadding: 왼쪽에 적용할 여백 크기.
     - rightPadding: 오른쪽에 적용할 여백.
     **/
    func wrappedPaddingContainer(
        stackView: UIStackView,
        topPadding: CGFloat,
        leftPadding: CGFloat,
        rightPadding: CGFloat,
        bottomPadding: CGFloat
    ) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(containerView)
        containerView.addSubview(self)
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topPadding),
            self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leftPadding),
            self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -rightPadding),
            self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -bottomPadding),
        ])
    }

    /**
     주어진 뷰를 컨테이너 뷰로 감싸 좌우 여백을 적용하고 `stackView`에 추가하는 래퍼(Wrapper) 함수.
     - Parameters:
     - stackView: container와 view를 담을 스택.
     - view: 여백을 적용할 대상 뷰.
     - allPadding: 왼쪽에 적용할 여백.
     **/
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

    /**
     주어진 뷰를 컨테이너 뷰로 감싸 좌우 여백을 적용하고 `stackView`에 추가하는 래퍼(Wrapper) 함수.
     - Parameters:
     - stackView: container와 view를 담을 스택.
     - view: 여백을 적용할 대상 뷰.
     - horizontalPadding: 양쪽에 가로방향에 적용할 여백.
     **/
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

    /**
     주어진 뷰를 컨테이너 뷰로 감싸 좌우 여백을 적용하고 `stackView`에 추가하는 래퍼(Wrapper) 함수.
     - Parameters:
     - stackView: container와 view를 담을 스택.
     - view: 여백을 적용할 대상 뷰.
     - verticalPadding: 양쪽 세로방향에 적용할 여백.
     **/
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
