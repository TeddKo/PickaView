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

            tableView.reloadData()
        }
    }

    extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

        func numberOfSections(in tableView: UITableView) -> Int {
            return 2
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 5  // 각 섹션에 1개씩 셀 표시
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.section == 0 {
                // 이제 videos 전달 불필요
                let cell = tableView.dequeueReusableCell(withIdentifier: "shortVideoTableViewCell", for: indexPath) as! ShortVideoTableViewCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "longVideoTableViewCell", for: indexPath) as! LongVideoTableViewCell
                cell.userNameLabel.text = "User"
                cell.viewsLabel.text = "Views: 1000"
                cell.durationLabel.text = "3:45"
                cell.userImage.image = UIImage(systemName: "person.crop.circle")
                cell.longVideoThumnail.image = UIImage(systemName: "video.fill")
                return cell
            }
        }
    }
