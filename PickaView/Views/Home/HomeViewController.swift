//
//  HomeViewController.swift
//  PickaView
//
//  Created by juks86 on 6/10/25.
//

import UIKit

struct DummyVideo {
    let user: String
    let views: Int
    let duration: Int
    let userImageSymbol: String
    let thumbnailSymbol: String
}


class HomeViewController: UIViewController {
    
    var viewModel: HomeViewModel!



    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var searchBar: UISearchBar!


    //가져온 비디오리스트를 저장하는 배열
    private var videoList: [DummyVideo] = [
           DummyVideo(user: "Alice", views: 1200, duration: 85, userImageSymbol: "person.crop.circle", thumbnailSymbol: "video"),
           DummyVideo(user: "Bob", views: 3000, duration: 210, userImageSymbol: "person.crop.circle.fill", thumbnailSymbol: "film"),
           DummyVideo(user: "Charlie", views: 560, duration: 45, userImageSymbol: "person.circle", thumbnailSymbol: "tv"),
           DummyVideo(user: "Diana", views: 14000, duration: 132, userImageSymbol: "person.crop.square", thumbnailSymbol: "play.rectangle")
       ]

       override func viewDidLoad() {
           super.viewDidLoad()
           collectionView.dataSource = self
           collectionView.delegate = self


       }


       // 비디오 길이를 "분:초" 형식으로 변환
     func formatDuration(_ duration: Int) -> String {
            let minutes = duration / 60
            let seconds = duration % 60
            return String(format: "%d:%02d", minutes, seconds)
        }

    	//화면 회전 시 레이아웃 업데이트
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            coordinator.animate(alongsideTransition: { _ in
                self.collectionView.collectionViewLayout.invalidateLayout()//화면 회전시 셀 크기와 배치 다시 계산
                self.collectionView.reloadData()
            }, completion: nil)
        }
    }

	//UICollectionView 설정
    extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

        //셀은 비디오 개수 만큼 반환
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return videoList.count
        }

        //api에서 불러온 정보 각 셀에 저장
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! VideoCollectionViewCell

            let video = videoList[indexPath.item]
            cell.userNameLabel.text = video.user
            cell.viewsLabel.text = "Views: \(video.views)"
            cell.durationLabel.text = formatDuration(video.duration)
            cell.userImage.image = UIImage(systemName: video.userImageSymbol)
            cell.thumnail.image = UIImage(systemName: video.thumbnailSymbol)
            cell.thumnail.contentMode = .scaleAspectFit

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

extension HomeViewController: UISearchBarDelegate {

}

   // 이미지 URL을 비동기적으로 불러오는 UIImageView 확장
//extension UIImageView {
//    func loadImage(from url: URL?, thumbnailHeight: CGFloat = 0) {
//        guard let url else {
//            self.image = UIImage(systemName: "photo")
//            return
//        }
//
//        // 백그라운드 스레드에서 이미지 데이터 다운로드
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: url),
//               let image = UIImage(data: data) {
//                // 메인 스레드에서 이미지 뷰에 설정
//                DispatchQueue.main.async {
//                    self.image = image
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.image = UIImage(systemName: "photo")
//                }
//            }
//        }
//    }
//}

