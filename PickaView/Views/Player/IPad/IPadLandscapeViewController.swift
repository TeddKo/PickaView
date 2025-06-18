//
//  IPadLandscapeViewController.swift
//  PickaView
//
//  Created by 장지현 on 6/17/25.
//

import UIKit
import AVFAudio

/// 전체화면 모드 dismiss 시 호출되는 델리게이트 프로토콜
protocol IPadLandscapeViewControllerDelegate: AnyObject {
    func didDismissFullscreen()
}

class IPadLandscapeViewController: BasePlayerViewController, PlayerViewControllerDelegate {
    
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
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupIpadUI()
        
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
    
    // MARK: - UI 세팅
    
    func setupIpadUI() {
        guard let viewModel else { return }
        
        fullscreenButton.alpha = 1.0
        dismissButton.alpha = 1.0
        
        fullscreenButton.addTarget(self, action: #selector(handleFullscreenButtonTapped(_:)), for: .touchUpInside)
        
        dismissButton.addTarget(self, action: #selector(handleDismissButtonTapped(_:)), for: .touchUpInside)
        
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
        
        self.present(fullVC, animated: true)
    }
    
    /// 전체화면에서 복귀(dismiss)할 때 호출 (FullScreen → 일반모드)
    func didDismissFullscreen() {
        isFullscreenMode = false
        setNeedsUpdateOfSupportedInterfaceOrientations()
        
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
    
    /// 세로화면 진입
    func presentPortrait() {
        let storyboard = UIStoryboard(name: "Player", bundle: nil)
        
        guard let playerVC = storyboard.instantiateViewController(withIdentifier: String(describing: PlayerViewController.self)) as? PlayerViewController else { return }
        
        playerVC.modalPresentationStyle = .fullScreen
        playerVC.playerManager = playerManager
        playerVC.gestureHandler = gestureHandler
        
        if let playerManager, let layer = playerManager.playerLayer {
            playerVC.videoContainerView?.layer.addSublayer(layer)
            if let fullBounds = playerVC.videoContainerView?.bounds {
                playerManager.updatePlayerLayerFrame(to: fullBounds)
            }
        }
        
        self.present(playerVC, animated: true) {
            if let windowScene = playerVC.view.window?.windowScene {
                let orientationPrefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
                windowScene.requestGeometryUpdate(orientationPrefs) { error in
                    print("Orientation update error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Orientation
    
    /// 기기 방향 변경시 호출(가로 → 전체화면, 세로 → 복귀)
    @objc func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation
        if (orientation == .landscapeLeft || orientation == .landscapeRight), !isFullscreenMode {
            presentFullscreen()
        } else if orientation == .portrait, isFullscreenMode {
            // 전체화면에서 FullscreenPlayerViewController가 알아서 내려감
        }
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
    
    // 각 셀의 크기 계산
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        
        let insets: CGFloat = 8
        
        let itemWidth = width - 16 * 2
        
        return CGSize(width: width, height: (itemWidth * 9 / 16) + 60 + insets * 3)
    }
    
    // 셀 간 가로 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension IPadLandscapeViewController: UICollectionViewDelegateFlowLayout {
    // 셀 선택 시 동작 처리
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 0번째는 태그 셀이므로 무시
        guard let viewModel else { return }
        
        let selectedVideo = viewModel.videos[indexPath.item]
        replaceWithNewVideo(selectedVideo)
    }
    
    /// 현재 플레이어 화면을 닫고, 선택한 비디오로 새로운 PlayerViewController를 모달로 띄웁니다.
    /// - Parameter video: 새로 재생할 비디오 객체
    func replaceWithNewVideo(_ video: Video) {
        guard let presentingVC = self.presentingViewController else { return }
        
        // 현재 플레이어 화면을 닫은 뒤, 새 비디오로 다시 화면을 구성
        self.dismiss(animated: false) { [weak self] in
            guard let self, let viewModel = self.viewModel else { return }
            
            let storyboard = UIStoryboard(name: "IPadLandscape", bundle: nil)
            guard let newPlayerVC = storyboard.instantiateViewController(withIdentifier: String(describing: IPadLandscapeViewController.self)) as? IPadLandscapeViewController else {
                return
            }
            newPlayerVC.modalPresentationStyle = .fullScreen
            
            let newPlayerVM = PlayerViewModel(video: video, coreDataManager: viewModel.getCoreDataManager())
            let pm = PlayerManager()
            let gh = PlayerGestureHandler()
            
            newPlayerVC.viewModel = newPlayerVM
            newPlayerVC.playerManager = pm
            newPlayerVC.gestureHandler = gh
            
            presentingVC.present(newPlayerVC, animated: false)
        }
    }
}
