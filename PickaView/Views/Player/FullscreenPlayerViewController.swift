////
////  FullscreenPlayerViewController.swift
////  PickaView
////
////  Created by junil on 6/11/25.
////
//
//import UIKit
//import AVKit
//
//final class FullscreenPlayerViewController: UIViewController {
//    var player: AVPlayer?
//    private var playerLayer: AVPlayerLayer?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//
//        // 1. 영상 표시용 뷰 생성
//        let videoView = UIView()
//        videoView.backgroundColor = .black
//        videoView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(videoView)
//        NSLayoutConstraint.activate([
//            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            videoView.topAnchor.constraint(equalTo: view.topAnchor),
//            videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//
//        // 2. AVPlayerLayer를 새로 생성하여 추가
//        if let player = player {
//            let layer = AVPlayerLayer(player: player)
//            layer.frame = UIScreen.main.bounds
//            layer.videoGravity = .resizeAspect
//            videoView.layer.addSublayer(layer)
//            self.playerLayer = layer
//        }
//
//        // 3. 스와이프 다운 제스처
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissFullscreen))
//        swipeDown.direction = .down
//        view.addGestureRecognizer(swipeDown)
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        playerLayer?.frame = view.bounds
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .landscapeRight }
//    override var prefersStatusBarHidden: Bool { true }
//    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .all }
//
//    @objc func dismissFullscreen() {
//        if let presentingVC = presentingViewController as? PlayerViewController {
//            presentingVC.setOrientation(to: .portrait)
//        }
//        dismiss(animated: true)
//    }
//}

import UIKit
import AVKit

class FullscreenPlayerViewController: UIViewController {
    var playerLayer: AVPlayerLayer?
    var controlsOverlayView: UIView?
    weak var delegate: PlayerViewControllerDelegate?

    private var isDismissing = false
    private var isFullscreenMode = false

    override func viewDidLoad() {
        super.viewDidLoad()

        print(">> 전체화면 viewDidLoad")  // << 이거 추가

        view.backgroundColor = .black

        // 1. 레이어/오버레이
        if let playerLayer = playerLayer {
            playerLayer.frame = view.bounds
            view.layer.addSublayer(playerLayer)
        }
        if let controlsOverlayView = controlsOverlayView {
            view.addSubview(controlsOverlayView)
            controlsOverlayView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                controlsOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                controlsOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                controlsOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
                controlsOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        // 스와이프 다운(overlay와 view 모두에)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        controlsOverlayView?.addGestureRecognizer(swipeDown)

        // 기기 회전 옵저버
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation
        if orientation == .portrait {
            handleDismiss()
        }
    }

    // FullscreenPlayerViewController.swift
    @objc func handleDismiss() {
        print(">> 전체화면: handleDismiss 호출") // << 이거 추가

        guard !isDismissing else { return }
        isDismissing = true

        // ✅ dismiss + delegate 호출 (PlayerViewController로!)
        dismiss(animated: true) { [weak self] in
            print(">> 전체화면 dismiss 완료, delegate 호출")
            self?.delegate?.didDismissFullscreen()
            self?.isDismissing = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }

    override var prefersStatusBarHidden: Bool { true }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .all }
}
