//
//  HomeViewController.swift
//  PickaView
//
//  Created by juks86 on 6/10/25.
//

import UIKit

class HomeViewController: UIViewController, ScrollToTopCapable {

    var viewModel: HomeViewModel?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    // 탭 바에서 스크롤 최상단으로 이동하는 메서드 (ScrollToTopCapable 프로토콜 채택)
    func scrollToTop() {
        guard let collectionView = self.collectionView else { return }
        let topOffset = CGPoint(x: 0, y: -collectionView.adjustedContentInset.top)
        collectionView.setContentOffset(topOffset, animated: true)
    }

    //가져온 비디오리스트를 저장하는 배열
    var videoList: [Video] = []
    //가져온 태그목록을 저장하는 배열
    var tags: [Tag] = []
    //필터링된 태그목록 저장하는 배열
    var filteredTags: [Tag] = []
    // 로딩 중인지 확인하는 bool 타입 변수
    var isLoading: Bool = true
    //태그에 맞는 비디오 목록이 표시됐는지 bool 타입으로 확인
    var isTagSearchActive: Bool = false

    //서치바에서 x	버튼 누르면 기존 비디오 배열을 보여준다
    var originalVideoList: [Video] = []

    private var isLoadingNextPage = false

    // 테이블뷰의 가시성 업데이트
    private func loadNextPageVideos() {
        guard !isLoadingNextPage else { return }  // 중복 호출 방지
        guard let viewModel = viewModel else { return }

        isLoadingNextPage = true

        Task {
            let nextPageVideos = viewModel.loadNextPage()
            if !nextPageVideos.isEmpty {
                await MainActor.run {
                    self.videoList.append(contentsOf: nextPageVideos)
                    self.collectionView.reloadData()
                    self.isLoadingNextPage = false
                }
            } else {
                // 더 불러올 비디오가 없으면 isLoadingNextPage 해제
                await MainActor.run {
                    self.isLoadingNextPage = false
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? VideoCollectionViewCell {
            if let indexPath = collectionView.indexPath(for: cell) {
                if let vc = segue.destination as? PlayerViewController {
                    if let viewModel {
                        vc.viewModel = PlayerViewModel(video: videoList[indexPath.item], coreDataManager: viewModel.getCoreDataManager())
                    }
                    vc.modalPresentationStyle = .fullScreen
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        collectionView.dataSource = self
        collectionView.delegate = self
        setupPullToRefresh()
        searchBar.delegate = self
        isLoading = true
        collectionView.reloadData()
        searchBar.searchTextField.delegate = self
        searchBar.searchBarStyle = .minimal
        // 서치바에서 자동 대문자 입력 방지
        (searchBar.value(forKey: "searchField") as? UITextField)?.autocapitalizationType = .none

        // 테이블뷰 초기 상태 숨기기
        updateTableViewVisibility(isVisible: false)

        // 비동기로 view모델에서 모든 태그 가져옴
        Task {
            // 1. 비디오 + 태그 저장
            await viewModel?.fetchAndSaveVideos()

            // 2. 저장된 태그 로드
            await viewModel?.loadAllTags()

            // 3. UI에 반영
            await MainActor.run {
                self.tags = viewModel?.allTags ?? []
                self.filteredTags = self.tags
                self.tableView.reloadData()
            }
        }

        Task {
            guard let viewModel = viewModel else {
                return
            }

            // 1. 초기에 네트워크 호출 후 데이터를 가져와서 Core Data에 저장
            await viewModel.fetchAndSaveVideos(query: nil)

            // 2. Core Data에서 정렬된 영상 불러와 내부 상태 갱신
            viewModel.refreshVideos()

            // 3. 첫 페이지에 해당하는 추천된 영상들 받아오기
            let videosFromViewModel = viewModel.getCurrentPageVideos()

            // 4. UI 업데이트는 메인 스레드에서
            await MainActor.run {
                self.isLoading = false
                self.videoList = videosFromViewModel
                self.collectionView.reloadData()
            }
        }
    }

    //화면 회전 시 레이아웃 업데이트
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard isViewLoaded else { return }
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()//화면 회전시 셀 크기와 배치 다시 계산
        }, completion: nil)
    }

    //새로고침 기능을 설정하는 함수
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    //화면 땡겼을 때 비디오 배열 추천 영상으로 새로고침
    @objc private func refresh() {

        Task {
            guard let viewModel = viewModel else { return }
            // Core Data에서 새로 로딩
            viewModel.refreshVideos()
            // UI 업데이트
            await MainActor.run {
                let refreshedVideos = viewModel.getCurrentPageVideos()
                self.videoList = refreshedVideos
                self.originalVideoList = refreshedVideos  // 리프레시 시 기존 비디오 배열도 업데이트
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()

                // 햅틱
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
            }

        }
    }
}

//UICollectionView 설정
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //셀은 비디오 개수 만큼 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 10 : videoList.count
    }
    // 코어데이터에서 불러온 정보 각 셀에 저장
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? VideoCollectionViewCell else {
            fatalError("Failed to dequeue VideoCollectionViewCell")
        }

        // 로딩 중일 때는 스켈레톤 뷰를 보여주고, 로딩이 끝나면 실제 데이터를 보여줌
        if isLoading {
            cell.configure(with: nil)
        } else {
            // 비디오 데이터가 로딩된 경우 셀을 구성
            let video = videoList[indexPath.item]
            cell.configure(with: video)
        }
        return cell
    }

    // 셀 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        //현재 컬렉션 뷰 크기
        let width = collectionView.bounds.width

        var itemsPerRow: CGFloat = 1 //한 행에 표시 할 아이템 수
        var insets: CGFloat = 10

        // 디바이스 및 방향에 따라 열 수 결정
        let isPad = traitCollection.userInterfaceIdiom == .pad //아이패드일 때

        let isLandscape = view.bounds.width > view.bounds.height

        if isPad {
            itemsPerRow = isLandscape ? 3 : 2 // 가로이면 셀 3개 아니면 2개 반환
        } else {
            itemsPerRow = isLandscape ? 2 : 1
            insets = isLandscape ? 10 : 0  // 아이폰 세로는 화면 꽉차게 설정
        }

        let spacing: CGFloat = 10 // 셀 간 간격
        let totalSpacing = spacing * (itemsPerRow - 1) + insets * 2
        let itemWidth = (width - totalSpacing) / itemsPerRow //한 줄에 몇개의 셀을 배치할지에 따라 셀의 너비 계산

        let thumbnailHeight = itemWidth * 9 / 16
        let userImageHeight = itemWidth / 5  // 유저 이미지높이는 전체 셀 너비의 20퍼센트로 설정
        let totalHeight = thumbnailHeight + userImageHeight

        return CGSize(width: itemWidth, height: totalHeight)
    }

    //줄 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }

    //셀 사이 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    //섹션마다의 여백
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        let isPhonePortrait = traitCollection.userInterfaceIdiom == .phone && width < height

        return isPhonePortrait ? .zero : UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

// 태그 목록을 표시하는 TableView 관련 설정
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // filteredTags를 기준으로 row 개수 리턴
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTags.isEmpty ? 1 : filteredTags.count
    }

    // 셀 구성 - 태그 목록 표시 또는 '검색 결과 없음' 플레이스홀더
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as? SearchTableViewCell else {
            return UITableViewCell()
        }

        if filteredTags.isEmpty {
            // 태그가 하나도 없으면 '검색 결과가 없습니다' 메시지
            cell.tagLabel.text = "No results found."
            cell.tagLabel.textColor = .gray
            cell.isUserInteractionEnabled = false
        } else {
            let tag = filteredTags[indexPath.row]
            cell.tagLabel.text = "#\(tag.name ?? "")"
            cell.tagLabel.textColor = .label
            cell.isUserInteractionEnabled = true
        }
        return cell
    }

    // 태그 선택 시 해당 태그로 필터링된 비디오 목록을 컬렉션뷰에 표시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !filteredTags.isEmpty else { return }
        guard let selectedTag = filteredTags[indexPath.row].name else { return }
        applyTagFilter(tagName: selectedTag)
    }

    // 특정 태그 이름으로 비디오 목록을 필터링하고 UI를 업데이트하는 함수
    func applyTagFilter(tagName: String) {
        //필터 적용 전에 원래 보이던 비디오 리스트 저장
        originalVideoList = videoList

        // 1. ViewModel에서 해당 태그 이름으로 필터링된 비디오 리스트를 가져옴
        let filteredVideos = viewModel?.fetchVideosForTag(tagName) ?? []

        // 2. 현재 비디오 리스트를 필터링된 비디오들로 교체
        videoList = filteredVideos

        // 3. 비디오 리스트가 바뀌었으니 컬렉션뷰를 새로고침해서 화면에 반영
        collectionView.reloadData()

        collectionView.setContentOffset(.zero, animated: false) //스크롤 최상단으로 이동

        isTagSearchActive = true
        collectionView.bounces = false

        // 4. 검색바에 #과 태그 이름을 붙여서 보여줌
        searchBar.text = "#\(tagName)"

        // 5. 검색바에서 키보드 내리기 (포커스 해제)
        searchBar.resignFirstResponder()

        // 6. 태그 검색 목록 테이블뷰 숨김 처리
        updateTableViewVisibility(isVisible: false)

        // 7. 태그 검색이 활성화된 상태로 표시
        isTagSearchActive = true
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 컬렉션뷰인 경우에만 처리
        guard scrollView == collectionView else { return }

        // 테이블뷰가 보일 때 (검색 중일 때) 컬렉션뷰 스크롤이 최상단 위로 못 올라가게 막기
        if tableView.isHidden == false {
            if scrollView.contentOffset.y < 0 {
                scrollView.contentOffset.y = 0
                return
            }
        }

        //태그된 상태 감지 하면 페이징 금지
        if isTagSearchActive {
            return
        }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        // 사용자가 스크롤을 끝에서 100pt 이내로 내렸다면 다음 페이지 로드
        if offsetY > contentHeight - height - 100 {
            loadNextPageVideos()
        }
    }
}

