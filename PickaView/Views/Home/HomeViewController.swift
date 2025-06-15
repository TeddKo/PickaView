//
//  HomeViewController.swift
//  PickaView
//
//  Created by juks86 on 6/10/25.
//

import UIKit

class HomeViewController: UIViewController {

    var viewModel: HomeViewModel?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    //가져온 비디오리스트를 저장하는 배열
    private var videoList: [Video] = []
	//가져온 태그목록을 저장하는 배열
    private var tags: [Tag] = []

    private var isLoadingNextPage = false

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
                    vc.viewModel = PlayerViewModel(video: videoList[indexPath.item])
                    vc.modalPresentationStyle = .fullScreen
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            performSegue(withIdentifier: "Player", sender: cell)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        searchBar.searchTextField.delegate = self
        tableView.isHidden = true
        tableViewHeightConstraint.constant = 0
        searchBar.searchBarStyle = .minimal

        do {
            let coreDataManager = CoreDataManager()
            let pixabayVideoService = try PixabayVideoService()
            viewModel = HomeViewModel(coreDataManager: coreDataManager, pixabayVideoService: pixabayVideoService)
        } catch {
            print("CoreDataManager 초기화 실패: \(error)")
        }

        //비동기로 view모델에서 모든 태그 가져옴
        Task {
            await viewModel?.loadAllTags()
            await MainActor.run {
                self.tableView.reloadData()

            }
        }

        Task {
            guard let viewModel = viewModel else {
                print("viewModel이 아직 초기화되지 않았습니다.")
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
}

//UICollectionView 설정
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //셀은 비디오 개수 만큼 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoList.count
    }

    // 코어데이터에서 불러온 정보 각 셀에 저장
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? VideoCollectionViewCell else {
            fatalError("Failed to dequeue VideoCollectionViewCell")
        }

        let video = videoList[indexPath.item]
        cell.configure(with: video)
        return cell
    }


    // 셀 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        //현재 컬렉션 뷰 크기
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height

        var itemsPerRow: CGFloat = 1 //한 행에 표시 할 아이템 수
        var insets: CGFloat = 10

        // 디바이스 및 방향에 따라 열 수 결정
        let isPad = traitCollection.userInterfaceIdiom == .pad //아이패드일 때
        let isLandscape = width > height // 가로일때

        if isPad {
            itemsPerRow = isLandscape ? 3 : 2 // 가로이면 셀 3개 아니면 2개 반환
        } else {
            itemsPerRow = isLandscape ? 2 : 1
            insets = isLandscape ? 10 : 0  // 아이폰 세로는 화면 꽉차게 설정
        }

        let spacingBetweenViews: CGFloat = 6.33
        let spacing: CGFloat = 10 // 셀 간 간격
        let totalSpacing = spacing * (itemsPerRow - 1) + insets * 2
        let itemWidth = (width - totalSpacing) / itemsPerRow //한 줄에 몇개의 셀을 배치할지에 따라 셀의 너비 계산

        let thumbnailHeight = itemWidth * 9 / 16
        let userImageHeight = itemWidth / 5  // 유저 이미지높이는 전체 셀 너비의 20퍼센트로 설정
        let totalHeight = thumbnailHeight + userImageHeight + spacingBetweenViews

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

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.allTags.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as? SearchTableViewCell else {
            return UITableViewCell()
        }
        if let tag = viewModel?.allTags[indexPath.row] {
            cell.tagLabel.text = "#\(tag.name ?? "")"
        }
        return cell
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 컬렉션뷰인 경우에만 처리
        guard scrollView == collectionView else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        // 사용자가 스크롤을 끝에서 100pt 이내로 내렸다면 다음 페이지 로드
        if offsetY > contentHeight - height - 100 {
            loadNextPageVideos()
        }
    }
}

