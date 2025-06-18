//
//  MyPageViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

import UIKit
import DGCharts
import Combine

/// 마이페이지 화면을 표시하고 관리하는 뷰 컨트롤러.
///
/// 사용자의 활동 데이터(시청 기록, 차트) 표시 및 앱의 화면 테마 설정 기능을 포함함.
class MyPageViewController: UIViewController {
    
    /// 뷰의 데이터와 비즈니스 로직을 관리하는 뷰모델.
    var viewModel: MyPageViewModel?
    /// Combine 구독을 관리하기 위한 Set.
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
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        return stackView
    }()
    
    /// 최근 시청 비디오를 표시하는 컬렉션뷰의 레이아웃.
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        return layout
    }()
    
    /// 최근 시청 비디오를 수평으로 표시하는 컬렉션뷰.
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
    
    /// 시청 기록이 없을 때 표시되는 레이블.
    private let emptyHistoryLabel: UILabel = {
       let label = UILabel()
        label.text = "history data is empty"
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    /// 시청 시간 통계를 보여주는 바(Bar) 차트 뷰.
    private let chartView: ChartView = ChartView()
    
    /// 오늘 및 주간 시청 시간을 표시하는 커스텀 뷰.
    private let todayLabelView = TwoLabelRowView()
    private let weakLabelVeiw = TwoLabelRowView()
    
    /// 앱의 화면 테마(라이트/다크/시스템)를 변경하기 위한 `UISegmentedControl`.
    private lazy var colorModeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Light", "Dark", "System"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(themeDidChange), for: .valueChanged)
        return segment
    }()
    
    // MARK: - Lifecycle
    
    /// 뷰 컨트롤러의 뷰가 메모리에 로드된 후 호출되는 생명주기 메서드.
    ///
    /// UI 레이아웃 설정, 뷰모델 바인딩 등 초기화 작업을 수행함.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        setupLayout()
        addViewsToStackView()
        bindViewModel()
    }
    
    /// 뷰가 화면에 나타나기 직전에 호출되는 생명주기 메서드.
    ///
    /// FRC(Fetched Results Controller)를 새로고침하여 최신 데이터를 반영함.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = viewModel else { return }
        
        viewModel.refreshFRC()
    }
    
    /// ViewModel의 @Published 프로퍼티 변경사항을 구독하고 UI를 업데이트함.
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.$weakHistory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] histories in
                self?.chartView.setData(with: histories)
            }
            .store(in: &cancellables)
        
        viewModel.$todayWatchTimeString
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] todayWatchTimeString in
                self?.todayLabelView.configure(leftText: "Today", rightText: todayWatchTimeString)
            }
            .store(in: &cancellables)
        
        viewModel.$weakWatchTimeString
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] weakWatchTimeString in
                self?.weakLabelVeiw.configure(leftText: "last 7 days", rightText: weakWatchTimeString)
            }
            .store(in: &cancellables)
        
        viewModel.$watchedVideos
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] videos in
                guard let self = self else { return }
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
    
    /// 테마 변경 세그먼트 컨트롤의 값이 변경될 때 호출됨.
    /// - Parameter sender: 이벤트가 발생한 `UISegmentedControl` 객체.
    @objc private func themeDidChange(_ sender: UISegmentedControl) {
        ThemeManager.shared.setTheme(selectedIndex: sender.selectedSegmentIndex)
    }
    
    
    // MARK: - UI Configuration
    
    /// `mainVerticalStackView`에 화면을 구성하는 모든 UI 컴포넌트를 순서대로 추가함.
    private func addViewsToStackView() {
        addSegmentedController()
        addChartView()
        addLabelView()
        addFullWidthCollectionView()
    }
    
    /// 화면 설정(테마) 관련 UI 컴포넌트를 구성하고 스택뷰에 추가함.
    private func addSegmentedController() {
        colorModeSegment.selectedSegmentIndex = ThemeManager.shared.currentThemeIndex
        mainVerticalStackView.addArrangedSubview(colorModeSegment)
    }
    
    /// 시청 시간 차트 UI를 구성하고 스택뷰에 추가함.
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
        
        chartView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45).isActive = true
    }
   
    /// 시청 시간 레이블(오늘, 주간) UI를 구성하고 스택뷰에 추가함.
    private func addLabelView() {
        todayLabelView.configure(leftText: "Today", rightText: "0m")
        weakLabelVeiw.configure(leftText: "Last 7 days", rightText: "0m")
        
        mainVerticalStackView.addArrangedSubview(todayLabelView)
        mainVerticalStackView.addArrangedSubview(weakLabelVeiw)
    }
    
    /// 최근 시청 비디오를 보여주는 수평 스크롤 컬렉션뷰를 구성하고 스택뷰에 추가함.
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
        
        collectionView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2).isActive = true
    }
    
    // MARK: - Layout
    
    /// 스크롤뷰, 스택뷰 등 뷰 컨트롤러의 기본 레이아웃 제약조건을 설정함.
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(mainVerticalStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainVerticalStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            mainVerticalStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            mainVerticalStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            mainVerticalStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// 지정된 인덱스 경로에 있는 아이템의 크기를 계산하여 반환함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - collectionViewLayout: 레이아웃 정보를 관리하는 객체.
    ///   - indexPath: 크기를 계산할 아이템의 인덱스 경로.
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
    
    /// 지정된 섹션의 콘텐츠 인셋(여백)을 결정함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - collectionViewLayout: 레이아웃 정보를 관리하는 객체.
    ///   - section: 인셋을 적용할 섹션의 인덱스.
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets.init(horizontal: 20)
    }
    
    /// 사용자가 특정 셀을 선택했을 때 호출됨.
    ///
    /// 선택된 비디오의 플레이어 화면으로 전환함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - indexPath: 선택된 셀의 인덱스 경로.
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
    
    /// 지정된 섹션에 표시할 아이템의 총 개수를 반환함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - section: 아이템 개수를 요청하는 섹션의 인덱스.
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let totalCount = viewModel?.watchedVideos.count ?? 0
        return min(totalCount, 20)
    }
    
    /// 특정 `indexPath`에 해당하는 셀을 생성하고 구성하여 반환함.
    /// - Parameters:
    ///   - collectionView: 이 메서드를 요청하는 컬렉션뷰.
    ///   - indexPath: 셀을 요청하는 위치의 인덱스 경로.
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
