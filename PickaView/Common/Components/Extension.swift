//
//  Extension.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/11/25.
//

import UIKit

extension UIImageView {
    /// `currentURL` 연관 객체(Associated Object)를 위한 안정적인 메모리 주소 키.
    private static var currentURLKey: Void?

    /// 셀 재사용 시 이미지 충돌을 방지하기 위해 현재 인스턴스에서 로딩 중인 이미지의 URL.
    private var currentURL: URL? {
        get {
            return objc_getAssociatedObject(self, &Self.currentURLKey) as? URL
        }
        set {
            objc_setAssociatedObject(self, &Self.currentURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    
    /// 지정된 URL 문자열에서 비동기적으로 이미지를 로드함.
    ///  
    /// - 캐시에서 이미지를 먼저 확인.
    /// - 캐시에 없는 경우, 네트워크를 통해 이미지를 다운로드.
    /// - 다운로드된 이미지를 현재 `UIImageView`의 크기에 맞게 리사이징.
    /// - 리사이징된 이미지를 캐시에 저장하여 향후 요청 시 재사용.
    /// - 셀 재사용으로 인한 이미지 뒤바뀜 현상을 방지.
    ///  
    /// - Parameter urlString: 로드할 이미지의 URL 주소.
    
    func loadImage(from urlString: String) {
        self.image = nil
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL string.")
            return
        }
        self.currentURL = url
        let cacheKey = urlString as NSString

        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        let targetSize = self.bounds.size

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if self.currentURL != url {
                return
            }

            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("Error: No data or could not create image.")
                return
            }

            let resizedImage = targetSize == .zero ? image : self.resizeImage(image, to: targetSize)
            
            ImageCacheManager.shared.setObject(resizedImage, forKey: cacheKey)

            DispatchQueue.main.async {
                if self.currentURL == url {
                    self.image = resizedImage
                }
            }
        }
        task.resume()
    }

  
    /// 주어진 `UIImage`를 목표 크기로 리사이징하는 private 헬퍼 메서드.
    /// 
    /// - Parameter image: 리사이징할 원본 이미지.
    /// - Parameter targetSize: 리사이징될 목표 크기.
    /// - Returns: 목표 크기로 리사이징된 새로운 이미지.
    
    private func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}


extension UIView {
    /// 특정 방향의 여백을 채우기 위한 UIView의 확장 래퍼함수.
    ///
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
    ///
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
    ///
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
    /// 
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
