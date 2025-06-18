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
    
    /// 지정된 URL 문자열에서 비동기적으로 이미지를 로드하고 `UIImageView`에 설정함.
    ///
    /// 캐시에서 이미지를 먼저 확인하고, 없으면 네트워크를 통해 다운로드함.
    /// 다운로드된 이미지는 캐시에 저장되며, 셀 재사용으로 인한 이미지 뒤바뀜 현상을 방지함.
    /// - Parameter urlString: 로드할 이미지의 URL 주소.
    func loadImage(from urlString: String) {
        self.image = nil
        self.isSkeletonable = true
        self.showAnimatedGradientSkeleton()

        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL string.")
            self.hideSkeleton()
            return
        }
        
        self.currentURL = url
        let cacheKey = urlString as NSString

        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            DispatchQueue.main.async {
                self.hideSkeleton()
                self.image = cachedImage
            }
            return
        }

        let targetSize = self.bounds.size

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if self.currentURL != url {
                DispatchQueue.main.async { self.hideSkeleton() }
                return
            }

            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async { self.hideSkeleton() }
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                print("Error: No data or could not create image.")
                DispatchQueue.main.async { self.hideSkeleton() }
                return
            }

            let resizedImage = targetSize == .zero ? image : self.resizeImage(image, to: targetSize)
            ImageCacheManager.shared.setObject(resizedImage, forKey: cacheKey)

            DispatchQueue.main.async {
                if self.currentURL == url {
                    self.hideSkeleton()
                    self.image = resizedImage
                }
            }
        }
        task.resume()
    }
  
    /// 주어진 `UIImage`를 목표 크기로 리사이징하는 private 헬퍼 메서드.
    ///
    /// - Parameters:
    ///   - image: 리사이징할 원본 이미지.
    ///   - targetSize: 리사이징될 목표 크기.
    /// - Returns: 목표 크기로 리사이징된 새로운 이미지.
    private func resizeImage(_ image: UIImage, to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}


extension UIView {
    /// 뷰를 컨테이너 뷰로 감싸고 지정된 여백을 적용한 후, 부모 스택뷰에 추가함.
    /// - Parameters:
    ///   - stackView: 부모가 될 `UIStackView`.
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
    
    /// 뷰를 컨테이너 뷰로 감싸고 모든 방향에 동일한 여백을 적용한 후, 부모 스택뷰에 추가함.
    /// - Parameters:
    ///   - stackView: 부모가 될 `UIStackView`.
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
    
    /// 뷰를 컨테이너 뷰로 감싸고 수평 방향에 동일한 여백을 적용한 후, 부모 스택뷰에 추가함.
    /// - Parameters:
    ///   - stackView: 부모가 될 `UIStackView`.
    ///   - horizontalPadding: 수평 방향(왼쪽, 오른쪽)에 적용할 여백.
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

    /// 뷰를 컨테이너 뷰로 감싸고 수직 방향에 동일한 여백을 적용한 후, 부모 스택뷰에 추가함.
    /// - Parameters:
    ///   - stackView: 부모가 될 `UIStackView`.
    ///   - verticalPadding: 수직 방향(위, 아래)에 적용할 여백.
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

extension UIEdgeInsets {
    
    /// 수평 방향(left, right)에만 값을 적용하여 `UIEdgeInsets`를 초기화함.
    /// - Parameter horizontal: 수평 방향에 적용할 여백 값.
    init(horizontal: CGFloat) {
        self.init(top: 0, left: horizontal, bottom: 0, right: horizontal)
    }
    
    /// 수직 방향(top, bottom)에만 값을 적용하여 `UIEdgeInsets`를 초기화함.
    /// - Parameter vertical: 수직 방향에 적용할 여백 값.
    init(vertical: CGFloat) {
        self.init(top: vertical, left: 0, bottom: vertical, right: 0)
    }
}
