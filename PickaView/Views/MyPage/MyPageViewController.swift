//
//  MyPageViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

import UIKit

/**
 마이페이지 화면을 표시하고 관리하는 뷰 컨트롤러.
 
 사용자의 활동 데이터 표시 및 앱의 화면 테마 설정 기능을 포함함.
 **/
class MyPageViewController: UIViewController {
    
    // MARK: - Properties
        
    /// 수평 스크롤 리스트를 위한 `UICollectionView`. `setupCollectionView()`에서 초기화됨.
    private var collectionView: UICollectionView!
    
    /// 컬렉션뷰에 표시할 색상 데이터 소스.
    private var colors: [UIColor] = []
    
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
        return stackView
    }()
    
    /// 화면 테마 변경을 위한 `UISegmentedControl`. `lazy` 키워드를 통해 첫 사용 시 초기화됨.
    private lazy var colorModeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["라이트", "다크", "시스템"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(themeDidChange), for: .valueChanged)
        return segment
    }()
    
    // MARK: - Lifecycle
    
    /// 뷰 컨트롤러의 뷰가 메모리에 로드된 후 호출되는 생명주기 메서드.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        addColors()
        addViewsToStackView()
    }
    
    // MARK: - Theme Logic
    
    /**
     `colorModeSegment`의 값이 변경될 때 호출될 메서드.
     - Parameter sender: 이벤트가 발생한 `UISegmentedControl` 객체.
     **/
    @objc private func themeDidChange(_ sender: UISegmentedControl) {
        ThemeManager.shared.setTheme(selectedIndex: sender.selectedSegmentIndex)
    }
    
    
    // MARK: - UI Configuration
    
    /// `colors` 배열에 50개의 무작위 `UIColor` 인스턴스를 생성하여 추가함.
    private func addColors() {
        for _ in 0..<50 {
            colors.append(generateRandomColor())
        }
    }
    
    /// `mainVerticalStackView`에 화면을 구성하는 모든 UI 컴포넌트를 순서대로 추가.
    private func addViewsToStackView() {
        addSegmentedController()
        addChartView()
        horizontalStackTwoTextView(leftText: "Today", rightText: "2 hours 8 minutes")
        horizontalStackTwoTextView(leftText: "last 7 days", rightText: "25hours 8 minutes")
        addFullWidthCollectionView()
    }
    
    /**
     무작위 RGB 값을 가진 `UIColor` 객체를 생성하여 반환.
     - Returns: 생성된 `UIColor` 객체.
     **/
    private func generateRandomColor() -> UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
    }
    
    /// 화면 설정(테마) 관련 UI 컴포넌트를 구성하고 스택뷰에 추가.
    private func addSegmentedController() {
        colorModeSegment.selectedSegmentIndex = ThemeManager.shared.currentThemeIndex
        mainVerticalStackView.addArrangedSubview(colorModeSegment)
    }
    
    /// 시청 시간 차트 UI를 구성하고 스택뷰에 추가.
    private func addChartView() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        
        let chartView = UIView()
        chartView.backgroundColor = .systemGray4
        
        let label = UILabel()
        label.text = "시청시간"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        
        wrappedPaddingContainer(
            stackView: mainVerticalStackView,
            view: stackView,
            leftPadding: 20,
            rightPadding: 20
        )
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(chartView)
        
        // 차트 뷰의 높이를 부모 뷰 너비의 45%로 설정.
        chartView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45).isActive = true
    }
    
    /**
     두 개의 텍스트를 수평으로 배치하는 UI 컴포넌트를 생성하여 스택뷰에 추가.
     - Parameters:
       - leftText: 왼쪽에 표시될 텍스트.
       - rightText: 오른쪽에 표시될 텍스트.
     **/
    private func horizontalStackTwoTextView(leftText: String, rightText: String) {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        let leftLabel = UILabel()
        leftLabel.text = leftText
        leftLabel.font = .preferredFont(forTextStyle: .body)
        leftLabel.textAlignment = .left
        
        let rightLabel = UILabel()
        rightLabel.text = rightText
        rightLabel.font = .preferredFont(forTextStyle: .body)
        rightLabel.textAlignment = .right
        
        wrappedPaddingContainer(
            stackView: mainVerticalStackView,
            view: stackView,
            leftPadding: 20,
            rightPadding: 20
        )
        
        stackView.addArrangedSubview(leftLabel)
        stackView.addArrangedSubview(rightLabel)
    }
    
    /// 수평 스크롤 컬렉션뷰를 구성하고 스택뷰에 추가.
    private func addFullWidthCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(RandomColorCollectionViewCell.self, forCellWithReuseIdentifier: RandomColorCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        mainVerticalStackView.addArrangedSubview(collectionView)
        
        // 컬렉션뷰의 높이를 부모 뷰 너비의 20%로 설정.
        collectionView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2).isActive = true
    }
    
    // MARK: - Layout
    
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
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyPageViewController: UICollectionViewDelegateFlowLayout {
    
    /// 각 셀의 크기를 동적으로 계산하여 반환.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // 아이패드에서는 뷰가 너무 커보일 수 있으므로, 기기에 따라 비율을 다르게 적용
        let widthPercentage: CGFloat
        if traitCollection.horizontalSizeClass == .compact {
            widthPercentage = 0.3 // 아이폰
        } else {
            widthPercentage = 0.2 // 아이패드
        }
        
        let itemWidth = collectionView.bounds.width * widthPercentage
        
        // 셀 높이를 컬렉션뷰의 높이와 동일하게 설정.
        let itemHeight = collectionView.bounds.height
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    /// 섹션의 콘텐츠 인셋(insets)을 결정.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        // 상하 여백을 0으로 설정하여 셀이 컬렉션뷰의 높이를 완전히 채우도록 함.
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}

// MARK: - UICollectionViewDataSource
extension MyPageViewController: UICollectionViewDataSource {
    /// 섹션에 표시할 아이템의 총 개수를 반환.
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return colors.count
    }
    
    /// 특정 `indexPath`에 해당하는 셀을 생성하고 구성하여 반환.
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RandomColorCollectionViewCell.identifier,
            for: indexPath
        ) as? RandomColorCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: colors[indexPath.item])
        return cell
    }
}
