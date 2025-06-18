//
//  FullscreenPlayerViewController.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//

import UIKit
import AVKit

/// 전체화면 영상 플레이어 뷰 컨트롤러
class FullscreenPlayerViewController: BasePlayerViewController {

    // MARK: - Properties
    /// 전체화면 dismiss 시 호출될 델리게이트
    weak var delegate: PlayerViewControllerDelegate?
    
    /// 중복 dismiss 방지용 플래그
    private var isDismissing = false
    
    // MARK: - Lifecycle

    /// 뷰가 메모리에 올라왔을 때 호출
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullscreenButton.alpha = 1.0
        
        fullscreenButton.setImage(UIImage(systemName: "arrow.up.forward.and.arrow.down.backward.rectangle"), for: .normal)
        
        fullscreenButton.addTarget(self, action: #selector(handleFullscreenButtonTapped(_:)), for: .touchUpInside)
        
        // 기기 회전 감지(세로 전환 시 전체화면 닫기)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        // 앱이 백그라운드로 진입할 때 알림 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        // AVPlayerLayer 추가
//        if let playerLayer = playerLayer {
//            playerLayer.frame = view.bounds
//            view.layer.addSublayer(playerLayer)
//        }
//
//        // 오버레이 추가 및 오토레이아웃
//        if let controlsOverlayView = controlsOverlayView {
//            view.addSubview(controlsOverlayView)
//            controlsOverlayView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                controlsOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                controlsOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//                controlsOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
//                controlsOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            ])
//        }

//        exitFullscreenButton.translatesAutoresizingMaskIntoConstraints = false
//        exitFullscreenButton.setImage(UIImage(systemName: "arrow.up.forward.and.arrow.down.backward.rectangle"), for: .normal)
//        exitFullscreenButton.tintColor = .white
//        exitFullscreenButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
//        controlsOverlayView?.addSubview(exitFullscreenButton)
        
//        if let overlay = controlsOverlayView {
//            NSLayoutConstraint.activate([
//                exitFullscreenButton.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -16),
//                exitFullscreenButton.bottomAnchor.constraint(equalTo: overlay.bottomAnchor, constant: -37),
//                exitFullscreenButton.widthAnchor.constraint(equalToConstant: 25),
//                exitFullscreenButton.heightAnchor.constraint(equalToConstant: 25)
//            ])
//        }

        // 스와이프 다운 제스처(뷰/오버레이에 모두 등록)
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
//        swipeDown.direction = .down
//        view.addGestureRecognizer(swipeDown)
//        controlsOverlayView?.addGestureRecognizer(swipeDown)
// FIXME: requestDismissToHome구현해야하나?
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dismissButton.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Fullscreen Actions
    
    @objc func handleFullscreenButtonTapped(_ sender: UIButton) {
        animateButtonTap(sender) {
            self.handleDismiss()
        }
    }

    // MARK: - Orientation & Dismiss

    /// 기기 방향 변경 감지 시 호출 (세로면 dismiss)
    @objc
    private func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation
        if orientation == .portrait {
            handleDismiss()
        }
    }

    /// 전체화면 뷰 dismiss 처리 및 델리게이트 호출
    @objc
    private func handleDismiss() {
        guard !isDismissing else { return }
        isDismissing = true

        // dismiss 및 delegate 전달
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didDismissFullscreen()
            self?.isDismissing = false
        }
    }
    
    // MARK: - Overrides for BasePlayerViewController
    override func requestDismissToHome() {
        handleDismiss()
    }

    // MARK: - Status Bar & System Gesture

    /// 상태바 숨김
    override var prefersStatusBarHidden: Bool { true }

    /// 시스템 제스처 연기 (모든 엣지)
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .all }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }

    override var shouldAutorotate: Bool {
        return true
    }
}
