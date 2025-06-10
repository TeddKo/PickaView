//
//  HomeViewController.swift
//  PickaView
//
//  Created by juks86 on 6/10/25.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
}

    extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

        // Section 몇 개? → 2개 (유저 리스트 Section + 영상 Section)
        func numberOfSections(in tableView: UITableView) -> Int {
            return 2
        }

        // 각 Section마다 몇 개 Row(Cell) 보여줄지
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if section == 0 {
                return 1 // Section 0은 항상 하나의 Cell → CollectionView 들어감
            } else {
                return 10 // Section 1은 영상 10개 → Cell 10개
            }
        }

        // 각 Row(Cell)에 어떤 셀을 그릴지 → 여기서 UITableViewCell 만들어서 반환
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.section == 0 {
                // Section 0 → UserListTableViewCell 반환 (CollectionView 들어가는 Cell)
                let cell = tableView.dequeueReusableCell(withIdentifier: "shortVideoTableViewCell", for: indexPath)
                return cell
            } else {
                // Section 1 → 영상용 VideoTableViewCell 반환
                let cell = tableView.dequeueReusableCell(withIdentifier: "longVideoTableViewCell", for: indexPath) as! LongVideoTableViewCell
                // 셀의 제목 표시 (임시로 영상 번호 표시)
                cell.userNameLabel.text = "Video \(indexPath.row + 1)"
                return cell
            }
        }
    }
