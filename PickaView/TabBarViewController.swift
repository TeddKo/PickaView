//
//  TabBarViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/10/25.
//

import UIKit

class TabBarViewController: UITabBarController {
    private let viewModel = TabBarViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeManager.shared.applyTheme()
        print("initial")
        
        viewControllers = viewModel.makeTabViewControllers()
    }
}
