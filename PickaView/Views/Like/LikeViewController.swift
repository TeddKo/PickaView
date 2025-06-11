//
//  LikeViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/11/25.
//

import UIKit

class LikeViewController: UIViewController {
    
    var selectedIndexPath: IndexPath?
    
    /// 화면 전체 스크롤을 담당하는 `UIScrollView`.
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    /// 모든 UI 컴포넌트를 수직으로 정렬하는 메인 `UIStackView`.
    private let mainVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 36
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        addViewsToStackView()
    }
    
    private func addViewsToStackView() {
        addMedialView()
    }
    
    /// 기본 UI 컴포넌트(스크롤뷰, 스택뷰)의 제약조건을 설정.
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(mainVerticalStackView)
        
        NSLayoutConstraint.activate([
            // 스크롤뷰를 safeArea에 맞춤.
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 메인 스택뷰를 스크롤뷰의 콘텐츠 영역에 맞춤.
            mainVerticalStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            // 스택뷰의 너비를 스크롤뷰의 프레임 너비와 일치시켜 수직 스크롤만 가능하도록 제한.
            mainVerticalStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func addMedialView() {
        
        let mediaCell = LikeCellView()
        
        mediaCell.configure(
            date: .now,
            thumbnailURL: "https://picsum.photos/300/200",
            videoLength: 500,
            tags: ["테스트", "테스트", "테스트"]
        )
        
        mediaCell
            .wrappedPaddingContainer(
                stackView: mainVerticalStackView,
                horizontalPadding: 20
            )
    }
}
