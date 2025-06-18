//
//  PlayerViewController.swift
//  PickaView
//
//  Created by junil on 6/9/25.
//

import UIKit
import AVKit

// MARK: - Delegate Protocol

/// 전체화면 모드 dismiss 시 호출되는 델리게이트 프로토콜
protocol PlayerViewControllerDelegate: AnyObject {
    func didDismissFullscreen()
}

// MARK: - Main Player View Controller

/// 영상 재생 및 플레이어 UI를 담당하는 뷰 컨트롤러
class PlayerViewController: BasePlayerViewController, PlayerViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullscreenButton.alpha = 1.0
        dismissButton.alpha = 1.0
        
        fullscreenButton.addTarget(self, action: #selector(handleFullscreenButtonTapped(_:)), for: .touchUpInside)
        
        dismissButton.addTarget(self, action: #selector(handleDismissButtonTapped(_:)), for: .touchUpInside)
        
        // 기기 방향 변화 알림 등록
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dismissButton.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dismissButton.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !isReturningFromFullscreen, isBeingDismissed || isMovingFromParent {
            viewModel?.stopAndSaveWatching()
        }
    }
    
    // MARK: - Fullscreen & Dismiss Actions
    
    @objc func handleFullscreenButtonTapped(_ sender: UIButton) {
        animateButtonTap(sender) {
            self.presentFullscreen()
        }
    }
    
    @objc func handleDismissButtonTapped(_ sender: UIButton) {
        animateButtonTap(sender) {
            self.dismissVC()
        }
    }
    
    func dismissVC() {
        dismiss(animated: true)
    }
    
    // MARK: - 전체화면 진입/복귀
    
    /// 전체화면 모드 진입
    func presentFullscreen() {
        guard !isFullscreenMode else { return }
        isFullscreenMode = true
        
        let storyboard = UIStoryboard(name: "FullscreenPlayer", bundle: nil)
        
        guard let fullVC = storyboard.instantiateViewController(withIdentifier: String(describing: FullscreenPlayerViewController.self)) as? FullscreenPlayerViewController else { return }
        
        fullVC.modalPresentationStyle = .fullScreen
        fullVC.playerManager = playerManager
        fullVC.gestureHandler = gestureHandler
        fullVC.delegate = self
        
        if let playerManager, let layer = playerManager.playerLayer {
            fullVC.videoContainerView?.layer.addSublayer(layer)
            if let fullBounds = fullVC.videoContainerView?.bounds {
                playerManager.updatePlayerLayerFrame(to: fullBounds)
            }
        }
        
        self.present(fullVC, animated: true) {
            if let windowScene = fullVC.view.window?.windowScene {
                let orientationPrefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscape)
                windowScene.requestGeometryUpdate(orientationPrefs) { error in
                    print("Orientation update error: \(error)")
                }
            }
        }
    }
    
    /// 전체화면에서 복귀(dismiss)할 때 호출 (FullScreen → 일반모드)
    func didDismissFullscreen() {
        isFullscreenMode = false
        setNeedsUpdateOfSupportedInterfaceOrientations()
        
        // 화면 방향을 '세로'로 강제 설정
        let windowScene = view.window?.windowScene
        windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        
        if let playerManager, let layer = playerManager.playerLayer {
            layer.removeFromSuperlayer()
            videoContainerView.layer.insertSublayer(layer, at: 0)
            playerManager.updatePlayerLayerFrame(to: videoContainerView.bounds)
        }
        
        controlsOverlayView.removeFromSuperview()
        videoContainerView.addSubview(controlsOverlayView)
        controlsOverlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlsOverlayView.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            controlsOverlayView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            controlsOverlayView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            controlsOverlayView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),
        ])
    }
    
    // MARK: - Orientation
    
    // FIXME: 아이패드 가로일때
    /// 기기 방향 변경시 호출(가로 → 전체화면, 세로 → 복귀)
    @objc func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation
        if (orientation == .landscapeLeft || orientation == .landscapeRight), !isFullscreenMode {
            presentFullscreen()
        } else if orientation == .portrait, isFullscreenMode {
            // 전체화면에서 FullscreenPlayerViewController가 알아서 내려감
        }
    }
    
    func setOrientationLegacy(to orientation: UIInterfaceOrientation) {
        if let scene = view.window?.windowScene {
            let mask = UIInterfaceOrientationMask.portrait
            let preferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: mask)
            scene.requestGeometryUpdate(preferences, errorHandler: { error in
                print("Orientation update error: \(error)")
            })
        }
    }
    
    /// 현재 지원되는 화면 방향
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return isFullscreenMode ? .landscape : .portrait
    }
    
    /// 프리젠테이션시 기본 방향
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return isFullscreenMode ? .landscapeRight : .portrait
    }
    
    /// 자동회전 허용 여부
    override var shouldAutorotate: Bool { true }
    
    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
