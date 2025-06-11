//
//  FullscreenPlayerViewController.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//

import UIKit
import AVKit

final class FullscreenPlayerViewController: UIViewController {
    var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // 1. 영상 표시용 뷰 생성
        let videoView = UIView()
        videoView.backgroundColor = .black
        videoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoView)
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: view.topAnchor),
            videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // 2. AVPlayerLayer를 새로 생성하여 추가
        if let player = player {
            let layer = AVPlayerLayer(player: player)
            layer.frame = UIScreen.main.bounds
            layer.videoGravity = .resizeAspect
            videoView.layer.addSublayer(layer)
            self.playerLayer = layer
        }

        // 3. 스와이프 다운 제스처
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissFullscreen))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .landscapeRight }
    override var prefersStatusBarHidden: Bool { true }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .all }

    @objc func dismissFullscreen() {
        if let presentingVC = presentingViewController as? PlayerViewController {
            presentingVC.setOrientation(to: .portrait)
        }
        dismiss(animated: true)
    }
}
