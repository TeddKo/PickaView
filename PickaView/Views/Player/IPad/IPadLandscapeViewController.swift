//
//  IPadLandscapeViewController.swift
//  PickaView
//
//  Created by 장지현 on 6/17/25.
//

import UIKit
import AVFAudio

class IPadLandscapeViewController: UIViewController {
    
    var viewModel: PlayerViewModel?
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func like(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()

        guard let viewModel else {
            fatalError("PlayerViewController has been deallocated before like button tapped.")
        }
        let isCurrentlyLiked = viewModel.toggleLikeStatus()
        
        likeButton.tintColor = isCurrentlyLiked ? .main : .systemGray4

        UIView.animate(withDuration: 0.1,
                       animations: {
                           self.likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.1) {
                               self.likeButton.transform = CGAffineTransform.identity
                           }
                       })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 백그라운드 실행 금지
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .moviePlayback, options: [])
        
        if let viewModel, let videoURL = viewModel.videoURL {
            setupPlayer(with: videoURL)
        } else {
            print("Invalid video URL")
        }

        setUpIpadUI()
    }
    
    func setUpIpadUI() {
        guard let viewModel else { return }
        
        viewsLabel.text = viewModel.views
        
        if !viewModel.userImageURL.isEmpty {
            userImageView.loadImage(from: viewModel.userImageURL)
        } else {
            userImageView.image = UIImage(systemName: "person.circle")
        }
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
        
        usernameLabel.text = viewModel.user
        
        likeButton.tintColor = viewModel.isLiked ? .main : .systemGray4
    }
}

extension IPadLandscapeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel else { fatalError("viewModel nil") }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: IPadLandscapeCell.self), for: indexPath) as! IPadLandscapeCell
        
        let video = viewModel.videos[indexPath.item]
        
        cell.configure(with: video)
        return cell
    }
}
