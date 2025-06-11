//
//  FullscreenPlayerViewController.swift
//  PickaView
//
//  Created by junil on 6/10/25.
//

import UIKit
import AVKit

class FullscreenPlayerViewController: UIViewController {

    var interactiveAnimator: UIPercentDrivenInteractiveTransition?

    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    weak var delegate: FullscreenPlayerViewControllerDelegate?

    // 기기 방향을 가로로 강제하고, 세로 모드는 지원하지 않음
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // 아래로 스와이프하여 dismiss하는 제스처 추가
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let progress = translation.y / view.bounds.height // 아래로 스와이프 시 progress 증가

        switch recognizer.state {
        case .began:
            interactiveAnimator = UIPercentDrivenInteractiveTransition()
            dismiss(animated: true)

        case .changed:
            interactiveAnimator?.update(progress)

        case .ended:
            if progress > 0.3 {
                interactiveAnimator?.finish()
            } else {
                interactiveAnimator?.cancel()
            }
            interactiveAnimator = nil

        default:
            break
        }
    }
}
