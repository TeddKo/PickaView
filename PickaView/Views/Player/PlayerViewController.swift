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
class PlayerViewController: UIViewController, PlayerViewControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var rateTwoView: UIView!
    
    var viewModel: PlayerViewModel!
    
    private var videoPlayerHeightConstraint: NSLayoutConstraint?

    // MARK: - Player Properties

    /// AVPlayer 인스턴스 (영상 재생)
    var player: AVPlayer?

    /// 영상 레이어(재생 화면용)
    var playerLayer: AVPlayerLayer?

    /// 재생 시간 관찰 토큰 (clean-up용)
    var timeObserverToken: Any?

    /// 현재 재생 상태
    var isPlaying = true

    /// 컨트롤 표시 여부
    var areControlsVisible = true

    /// 컨트롤 자동 숨김 타이머
    var controlsHideTimer: Timer?

    /// 세로 레이아웃 제약 목록
    var portraitConstraints: [NSLayoutConstraint] = []

    /// 가로 레이아웃 제약 목록
    var landscapeConstraints: [NSLayoutConstraint] = []

    /// 전체화면 모드 여부
    var isFullscreenMode: Bool = false
    
    /// 전체화면에서 돌아오는 상태 추적 변수
    var isReturningFromFullscreen: Bool = false

    /// 전체화면 dismiss 델리게이트
    weak var delegate: PlayerViewControllerDelegate?

    // MARK: - UI Components

    /// 재생/정지, 앞뒤 버튼 스택
    lazy var playbackControlsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backwardButton, playPauseButton, forwardButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 40
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    /// 시커(현재시간/슬라이더/총시간) 스택
    lazy var seekerStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentTimeLabel, progressSlider, totalDurationLabel])
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    /// 영상 표시 영역
    let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// 플레이어 컨트롤 오버레이
    let controlsOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// 재생/일시정지 버튼
    lazy var playPauseButton: UIButton = {
        let button = createButton(systemName: "play.fill")
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        return button
    }()

    /// 10초 뒤로 버튼
    lazy var backwardButton: UIButton = {
        let button = createButton(systemName: "10.arrow.trianglehead.counterclockwise", useSmallConfig: true)
        button.addTarget(self, action: #selector(backwardButtonTapped), for: .touchUpInside)
        return button
    }()

    /// 10초 앞으로 버튼
    lazy var forwardButton: UIButton = {
        let button = createButton(systemName: "10.arrow.trianglehead.clockwise", useSmallConfig: true)
        button.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
        return button
    }()

    /// 전체화면 버튼
    lazy var fullscreenButton: UIButton = {
        let button = createButton(systemName: "arrow.down.backward.and.arrow.up.forward.rectangle", useSmallConfig: true)
        button.addTarget(self, action: #selector(handleFullscreenButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 전체화면 취소 버튼
    lazy var exitFullscreenButton: UIButton = {
        let button = createButton(systemName: "arrow.up.forward.and.arrow.down.backward.rectangle", useSmallConfig: true)
        button.addTarget(self, action: #selector(handleFullscreenButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    /// 닫기 버튼
    lazy var dismissButton: UIButton = {
        let button = createButton(systemName: "xmark", useSmallConfig: true)
        button.addTarget(self, action: #selector(handleDismissButtonTapped(_:)), for: .touchUpInside)
        return button
    }()

    /// 현재 재생 위치 라벨
    lazy var currentTimeLabel: UILabel = {
        createTimeLabel(text: "00:00")
    }()

    /// 총 영상 길이 라벨
    lazy var totalDurationLabel: UILabel = {
        createTimeLabel(text: "00:00")
    }()

    /// 재생 위치 슬라이더
    lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.tintColor = .main
        slider.thumbTintColor = .main
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)

        let smallThumb = UIImage.circle(diameter: 18, color: .main)
        slider.setThumbImage(smallThumb, for: .normal)

        return slider
    }()

    // MARK: - LifeCycle

    /// 뷰가 로드될 때 초기 세팅
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayerHieght(for: view.bounds.size)
        // 백그라운드 실행 금지
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .moviePlayback, options: [])
        
        if let viewModel, let videoURL = viewModel.videoURL {
            setupPlayer(with: videoURL)
        } else {
            print("Invalid video URL")
        }
        
        setupUI()
        setPlayPauseImage(isPlaying: true)
        fullscreenButton.alpha = 1.0
        dismissButton.alpha = 1.0
        setupGestures()
        addPlayerObservers()
        
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

        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
        exitFullscreenButton.isHidden = true
        fullscreenButton.isHidden = false
        dismissButton.isHidden = false
    }

    /// 뷰가 사라질 때 전체화면 delegate 호출
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        delegate?.didDismissFullscreen()

        if !isReturningFromFullscreen, isBeingDismissed || isMovingFromParent {
            viewModel?.stopAndSaveWatching()
        }
    }

    /// 뷰의 크기 변경시 AVPlayerLayer 리사이즈
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
        collectionView.collectionViewLayout.invalidateLayout()
    }

    override func viewWillTransition(
        to size: CGSize,
        with coordinator: any UIViewControllerTransitionCoordinator
    ) {
        guard isViewLoaded else { return }
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        })
        setupPlayerHieght(for: size)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
        exitFullscreenButton.isHidden = false
        fullscreenButton.isHidden = true
        dismissButton.isHidden = true
    }

    // MARK: - Player Controls

    /// 3초 후 컨트롤 자동 숨김 예약
    func scheduleControlsHide() {
        cancelControlsHide()
        controlsHideTimer = Timer.scheduledTimer(
            timeInterval: 3.0,
            target: self,
            selector: #selector(hideControls),
            userInfo: nil,
            repeats: false
        )
    }

    /// 컨트롤 자동 숨김 예약 취소
    func cancelControlsHide() {
        controlsHideTimer?.invalidate()
        controlsHideTimer = nil
    }

    /// 컨트롤(버튼/시커) 숨기기 애니메이션
    @objc func hideControls() {
        areControlsVisible = false
        UIView.animate(withDuration: 0.3) {
            self.playbackControlsStack.alpha = 0.0
            self.seekerStack.alpha = 0.0
            self.fullscreenButton.alpha = 0.0
            self.exitFullscreenButton.alpha = 0.0
            self.dismissButton.alpha = 0.0
        }
    }

    /// 재생/일시정지 버튼 클릭 핸들러
    @objc func playPauseButtonTapped() {
        guard let player = self.player else { return }
  
        animateButtonTap(playPauseButton) { [weak self] in
            guard let self = self else { return }
                                           
            if !self.isPlaying,
               let player = self.player,
               player.currentItem?.currentTime() == player.currentItem?.duration {
                player.seek(to: .zero)
            }
                                           
            self.isPlaying.toggle()
            self.setPlayPauseImage(isPlaying: self.isPlaying)

            if self.isPlaying {
                player.play()
                self.viewModel?.startWatching()
                self.scheduleControlsHide()
            } else {
                player.pause()
                self.viewModel?.pauseWatching()
                self.cancelControlsHide()
            }
        }
    }

    @objc func handleFullscreenButtonTapped(_ sender: UIButton) {
        animateButtonTap(sender) {
            self.presentFullscreen()
        }
    }

    @objc func handleDismissButtonTapped(_ sender: UIButton) {
        animateButtonTap(sender) {
            self.handleSwipeDownToHome(UISwipeGestureRecognizer())
        }
    }

    /// 10초 뒤로 버튼 클릭 핸들러
    @objc func backwardButtonTapped() {
        animateButtonSpin(backwardButton, clockwise: true) {
            self.seek(by: -10)
        }
    }

    /// 10초 앞으로 버튼 클릭 핸들러
    @objc func forwardButtonTapped() {
        animateButtonSpin(forwardButton, clockwise: false) {
            self.seek(by: 10)
        }
    }

    /// 재생 위치 슬라이더 값 변경 핸들러
    @objc func sliderValueChanged(_ slider: UISlider) {
        guard let player = self.player, let duration = player.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(slider.value) * totalSeconds
        let seekTime = CMTime(value: Int64(value), timescale: 1)
        player.seek(to: seekTime)
        resetControlsHideTimer()
        setPlayPauseImage(isPlaying: isPlaying)
    }

    /// 영상 재생이 끝났을 때 호출됨 (자동 초기화)
    @objc func playerDidFinishPlaying() {
        isPlaying = false
        viewModel?.pauseWatching()
        let playImage = UIImage(systemName: "arrow.clockwise", withConfiguration: symbolConfig)
        playPauseButton.setImage(playImage, for: .normal)
        areControlsVisible = true
        rateTwoView.isHidden = true
        cancelControlsHide()
        
        UIView.animate(withDuration: 0.3) {
                self.playbackControlsStack.alpha = 1.0
                self.seekerStack.alpha = 1.0
                self.fullscreenButton.alpha = 1.0
                self.exitFullscreenButton.alpha = 1.0
                self.dismissButton.alpha = 1.0
            }
    }

    /// 컨트롤 자동 숨김 타이머 재설정
    func resetControlsHideTimer() {
        if isPlaying {
            scheduleControlsHide()
        }
    }

    /// 버튼을 일정 각도로 돌렸다가 복귀하는 애니메이션
    /// - Parameters:
    ///   - button: 애니메이션할 버튼
    ///   - clockwise: 시계 방향 여부
    ///   - completion: 완료 핸들러
    func animateButtonSpin(_ button: UIButton, clockwise: Bool, completion: (() -> Void)? = nil) {
        button.layer.removeAllAnimations()
        let angle: CGFloat = clockwise ? -CGFloat.pi / 2 : CGFloat.pi / 2

        UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                button.transform = CGAffineTransform(rotationAngle: angle).scaledBy(x: 0.85, y: 0.85)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                button.transform = .identity
            }
        }, completion: { _ in
            completion?()
        })
    }

    // MARK: - 전체화면 진입/복귀

    /// 전체화면 모드 진입
    func presentFullscreen() {
        guard let viewModel else { return }
        guard !isFullscreenMode else { return }
        isFullscreenMode = true

        let fullscreenVC = FullscreenPlayerViewController(viewModel: viewModel)
        fullscreenVC.modalPresentationStyle = .fullScreen
        fullscreenVC.playerLayer = self.playerLayer
        fullscreenVC.controlsOverlayView = self.controlsOverlayView
        fullscreenVC.delegate = self
        fullscreenVC.exitFullscreenButton = self.exitFullscreenButton

        self.present(fullscreenVC, animated: true) {
            if #available(iOS 16.0, *) {
                if let windowScene = fullscreenVC.view.window?.windowScene {
                    let orientationPrefs = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscape)
                    windowScene.requestGeometryUpdate(orientationPrefs) { [weak self] _ in
                        self?.present(fullscreenVC, animated: true)
                    }
                }
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }

    /// 전체화면에서 복귀(dismiss)할 때 호출 (FullScreen → 일반모드)
    func didDismissFullscreen() {
        isFullscreenMode = false
        setNeedsUpdateOfSupportedInterfaceOrientations()

        // 화면 방향을 '세로'로 강제 설정
        if #available(iOS 16.0, *) {
            let windowScene = view.window?.windowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }

        // playerLayer, controlsOverlayView 다시 복구
        if let playerLayer = self.playerLayer {
            playerLayer.removeFromSuperlayer()
            videoContainerView.layer.insertSublayer(playerLayer, at: 0)
            playerLayer.frame = videoContainerView.bounds
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

        setupGestures()
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

    /// (legacy) iOS 16 미만에서 방향 강제 변경
    func setOrientationLegacy(to orientation: UIInterfaceOrientation) {
        if #available(iOS 16.0, *) {
            if let scene = view.window?.windowScene {
                let mask = UIInterfaceOrientationMask.portrait
                let preferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: mask)
                scene.requestGeometryUpdate(preferences, errorHandler: { error in
                    print("Orientation update error: \(error)")
                })
            }
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    private func setupPlayerHieght(for size: CGSize) {
        videoPlayerHeightConstraint?.isActive = false
        
        if traitCollection.userInterfaceIdiom == .pad {
            let isPortrait = size.width < size.height
            let heightMultiplier = isPortrait ? 0.4 : 0.3
            videoPlayerHeightConstraint = videoPlayerView.heightAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: heightMultiplier
            )
        }
        videoPlayerHeightConstraint?.isActive = true
    }

    /// 프리젠테이션시 기본 방향
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return isFullscreenMode ? .landscapeRight : .portrait
    }

    /// 자동회전 허용 여부
    override var shouldAutorotate: Bool { true }
    
    // MARK: - App Background Handling

    @objc private func appDidEnterBackground() {
        playPauseButtonTapped()
        viewModel?.pauseWatching()
    }

    // MARK: - Deinit

    /// 뷰컨트롤러 해제 시 클린업
    deinit {
        if let token = timeObserverToken { player?.removeTimeObserver(token) }
        NotificationCenter.default.removeObserver(self)
    }
}
