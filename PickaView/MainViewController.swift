//
//  MainViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/10/25.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeManager.shared.applyTheme()
        print("initial")
    }
}
