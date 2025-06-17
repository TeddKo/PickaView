//
//  MyPageViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

import UIKit
import DGCharts
import Combine

/**
 마이페이지 화면을 표시하고 관리하는 뷰 컨트롤러.
 
 사용자의 활동 데이터 표시 및 앱의 화면 테마 설정 기능을 포함함.
 **/
class MyPageViewController: UIViewController {
    
    var viewModel: MyPageViewModel?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Properties
    
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
    
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MyPageWatchedVideoCollectionViewCell.self, forCellWithReuseIdentifier: MyPageWatchedVideoCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let emptyHistoryLabel: UILabel = {
       let label = UILabel()
        label.text = "history data is empty"
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let chartView: ChartView = ChartView()
    
    private let todayLabelView = TwoLabelRowView()
    private let weakLabelVeiw = TwoLabelRowView()
    
    /// 화면 테마 변경을 위한 `UISegmentedControl`. `lazy` 키워드를 통해 첫 사용 시 초기화됨.
    private lazy var colorModeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Light", "Dark", "System"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(themeDidChange), for: .valueChanged)
        return segment
    }()
    
    // MARK: - Lifecycle
    
    /// 뷰 컨트롤러의 뷰가 메모리에 로드된 후 호출되는 생명주기 메서드.
    override func viewDidLoad() {
        super.viewDidLoad()
        let coreDataManager = CoreDataManager()
        
        viewModel = MyPageViewModel(coreDataManager: coreDataManager)
        
        setupLayout()
        
        addViewsToStackView()
        
        bindViewModel()
        viewModel?.fetchWeakHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = viewModel else { return }
        
        viewModel.refreshFRC()
        viewModel.fetchWeakHistory()
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.$weakHistory
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] histories in
                self?.chartView.setData(with: histories)
            }
            .store(in: &cancellables)
        
        viewModel.$todayWatchTimeString
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] todayWatchTimeString in
                print("todayWatchTimeString is \(todayWatchTimeString)")
                self?.todayLabelView.configure(leftText: "Today", rightText: todayWatchTimeString)
            }
            .store(in: &cancellables)
        
        viewModel.$weakWatchTimeString
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] weakWatchTimeString in
                print("weakWatchTimeString is \(weakWatchTimeString)")
                self?.weakLabelVeiw.configure(leftText: "last 7 days", rightText: weakWatchTimeString)
            }
            .store(in: &cancellables)
        
        viewModel.$watchedVideos
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] videos in
                guard let self = self else { return }
                print("current watched videos is \(videos)")
                if videos.isEmpty {
                    self.collectionView.backgroundView = self.emptyHistoryLabel
                } else {
                    self.collectionView.backgroundView = nil
                }
                self.collectionView.reloadData()
            }
            .store(in: &cancellables)
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
    
    /// `mainVerticalStackView`에 화면을 구성하는 모든 UI 컴포넌트를 순서대로 추가.
    private func addViewsToStackView() {
        addSegmentedController()
        addChartView()
        addLabelView()
        addFullWidthCollectionView()
    }
    
    /// 화면 설정(테마) 관련 UI 컴포넌트를 구성하고 스택뷰에 추가.
    private func addSegmentedController() {
        colorModeSegment.selectedSegmentIndex = ThemeManager.shared.currentThemeIndex
        mainVerticalStackView.addArrangedSubview(colorModeSegment)
    }
    
    /// 시청 시간 차트 UI를 구성하고 스택뷰에 추가.
    private func addChartView() {
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 16
            
            view.addSubview(stackView)
            
            return stackView
        }()
        
        
        chartView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "Watch Time"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        
        stackView.wrappedPaddingContainer(stackView: mainVerticalStackView, horizontalPadding: 20)
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(chartView)
        
        // 차트 뷰의 높이를 부모 뷰 너비의 45%로 설정.
        chartView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45).isActive = true
    }
   
    private func addLabelView() {
        todayLabelView.configure(leftText: "Today", rightText: "0m")
        weakLabelVeiw.configure(leftText: "Last 7 days", rightText: "0m")
        
        mainVerticalStackView.addArrangedSubview(todayLabelView)
        mainVerticalStackView.addArrangedSubview(weakLabelVeiw)
    }
    
    /// 수평 스크롤 컬렉션뷰를 구성하고 스택뷰에 추가.
    private func addFullWidthCollectionView() {
        let stack: UIStackView = {
            let stack = UIStackView()
            stack.distribution = .fillProportionally
            stack.spacing = 20
            stack.distribution = .fill
            stack.axis = .vertical
            return stack
        }()
        
        let horizontaLabelButtonView = HorizontalLabelButtonView()
        
        
        
        stack.addArrangedSubview(horizontaLabelButtonView)
        stack.addArrangedSubview(collectionView)
        
        horizontaLabelButtonView.setButtonTapAction { [weak self] in
            let storyboard = UIStoryboard(name: "MyPageHistories", bundle: nil)
           
            guard let self = self, let watchedVideos = self.viewModel?.watchedVideos, let historiesVC = storyboard.instantiateViewController(withIdentifier: "MyPageHistoriesViewController") as? MyPageHistoriesViewController else { return }
            
            historiesVC.watchedVideos = watchedVideos
            historiesVC.coreDataManager = self.viewModel?.getCoreDataManager()
            
            self.navigationController?.show(historiesVC, sender: self)
        }
        
        mainVerticalStackView.addArrangedSubview(stack)
        
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
extension MyPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// 각 셀의 크기를 동적으로 계산하여 반환.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let isPad = traitCollection.userInterfaceIdiom == .pad
        let widthPercentage: CGFloat = isPad ? 0.2 : 0.3
        let itemWidth = collectionView.bounds.width * widthPercentage
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
        return UIEdgeInsets.init(horizontal: 20)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let selectedVideo = viewModel?.watchedVideos[indexPath.item] else { return }
        guard let viewModel = viewModel else { return }
        
        let storyboard = UIStoryboard(name: "Player", bundle: nil)
        guard let playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController else { return }
        
        playerVC.viewModel = PlayerViewModel(video: selectedVideo, coreDataManager: viewModel.getCoreDataManager())
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true, completion: nil)
    }
    
    /// 섹션에 표시할 아이템의 총 개수를 반환.
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel?.watchedVideos.count ?? 0
    }
    
    /// 특정 `indexPath`에 해당하는 셀을 생성하고 구성하여 반환.
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MyPageWatchedVideoCollectionViewCell.identifier,
            for: indexPath
        ) as? MyPageWatchedVideoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let video = viewModel?.watchedVideos[indexPath.item] {
            cell.configure(with: video)
        }
        return cell
    }
}
