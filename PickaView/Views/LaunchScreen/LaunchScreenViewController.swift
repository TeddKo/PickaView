//
//  LaunchScreenViewController.swift
//  PickaView
//
//  Created by Ko Minhyuk on 6/5/25.
//

import UIKit

class LaunchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                // Network
                // CoreData

                await MainActor.run {
                    self.performSegue(withIdentifier: "ReplaceSegue", sender: nil)
                }
            } catch {
                print("SplashView fetch Error: \(error)")
            }
        }
    }
}
