//
//  HomeViewController.swift
//  PickaView
//
//  Created by juks86 on 6/10/25.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    //가져온 비디오리스트를 저장하는 배열
    var videoList: [PixabayVideo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        fetchVideoList()
    }

    // Pixabay API로부터 비디오 데이터를 가져오는 함수
    func fetchVideoList() {
        Task {
            do {
                //비디오 목록 비동기로 가져옴
                let videos = try await PixabayVideoService.shared.fetchVideos()
                self.videoList = videos

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ Error fetching videos: \(error)")
            }
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // 섹션 1개만 사용 (일반 비디오용)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoList.count // 불러온 비디오 개수만큼
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 일반 비디오 셀 구성
        let cell = tableView.dequeueReusableCell(withIdentifier: "longVideoTableViewCell", for: indexPath) as! LongVideoTableViewCell
        let video = videoList[indexPath.row]

        // 셀 값 설정
        cell.userNameLabel.text = video.user
        cell.viewsLabel.text = "Views: \(video.views)"
        cell.durationLabel.text = formatDuration(video.duration)
        cell.userImage.loadImage(from: URL(string: video.userImageURL))
        cell.longVideoThumnail.loadImage(from: URL(string: video.videos.medium.thumbnail))
        cell.longVideoThumnail.contentMode = .scaleToFill

        return cell
    }

    // 비디오 길이를 "분:초" 형식으로 변환
    func formatDuration(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // 셀 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280 // 일반 셀 높이
    }
}

// 이미지 URL을 비동기적으로 불러오는 UIImageView 확장
extension UIImageView {
    func loadImage(from url: URL?) {
        guard let url else {
            self.image = UIImage(systemName: "photo")
            return
        }

        // 백그라운드 스레드에서 이미지 데이터 다운로드
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                // 메인 스레드에서 이미지 뷰에 설정
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
