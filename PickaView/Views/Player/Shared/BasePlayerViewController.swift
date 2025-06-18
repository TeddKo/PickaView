//
//  BasePlayerViewController.swift
//  PickaView
//
//  Created by 장지현 on 6/17/25.
//

import UIKit
import AVFoundation

class BasePlayerViewController: UIViewController, PlayerGestureDelegate {
    
    @IBOutlet weak var videoContainerView: UIView!
    
    var playerManager: PlayerManager?
    var viewModel: PlayerViewModel?
    
    // MARK: - Player Properties
    
    /// 현재 재생 상태
    var isPlaying: Bool = true
    
    /// 컨트롤 표시 여부
    var areControlsVisible = true
    
    /// 컨트롤 자동 숨김 타이머
    var controlsHideTimer: Timer?
    
    /// 전체화면 모드 여부
    var isFullscreenMode: Bool = false
    
    /// 전체화면에서 돌아오는 상태 추적 변수
    var isReturningFromFullscreen: Bool = false

    /// Handler
    var gestureHandler: PlayerGestureHandler?
    
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
    let videoView: UIView = {
        let view = UIView()
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
        return button
    }()
    
    /// 닫기 버튼
    lazy var dismissButton: UIButton = {
        let button = createButton(systemName: "xmark", useSmallConfig: true)
        return button
    }()
    
    /// 2배속 재생 안내 뷰
    lazy var rateTwoView: UIView = {
        return createRateTwoView()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 백그라운드 실행 금지
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .moviePlayback, options: [])
        
        setupUI()
        setPlayPauseImage(isPlaying: isPlaying)
        
        if let viewModel, let videoURL = viewModel.videoURL {
            playerManager?.setupPlayer(with: videoURL)
            isPlaying = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        playerDidBecomeReadyToPlay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let playerManager, let gestureHandler else { return }
        
        playerManager.videoContainerView = videoContainerView
        playerManager.delegate = self
        
        gestureHandler.videoContainerView = videoContainerView
        gestureHandler.controlsOverlayView = controlsOverlayView
        gestureHandler.delegate = self
        gestureHandler.attachGestures()
        
        if let layer = playerManager.playerLayer {
            layer.removeFromSuperlayer()
            videoContainerView.layer.insertSublayer(layer, at: 0)
            playerManager.updatePlayerLayerFrame(to: videoContainerView.bounds)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Player Controls
    
    func playerDidBecomeReadyToPlay() {
        // FIXME: 나중에 확인
        // setupPlayer(with:)를 다시 호출하거나
        // player.replaceCurrentItem(with:) 후 .readyToPlay 상태를 대기
        // 위같은 경우에는 호출됨
        viewModel?.updateStartTime()
        viewModel?.startWatching()
        
        if isPlaying {
            scheduleControlsHide()
        }
    }
    
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
            self.dismissButton.alpha = 0.0
        }
    }
    
    /// 재생/일시정지 버튼 클릭 핸들러
    @objc func playPauseButtonTapped() {
        guard let playerManager else { return }
        
        animateButtonTap(playPauseButton) { [weak self] in
            guard let self = self,
                  let player = playerManager.player else { return }
            
            if !self.isPlaying,
               player.currentItem?.currentTime() == player.currentItem?.duration {
                player.seek(to: .zero)
                resetControlsHideTimer()
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
    
    /// 10초 뒤로 버튼 클릭 핸들러
    @objc func backwardButtonTapped() {
        animateButtonSpin(backwardButton, clockwise: true) { [weak self] in
            guard let self = self else { return }
            self.playerManager?.seek(by: -10)
            self.playerDidSeek()
            resetControlsHideTimer()
        }
    }
    
    /// 10초 앞으로 버튼 클릭 핸들러
    @objc func forwardButtonTapped() {
        animateButtonSpin(forwardButton, clockwise: false) { [weak self] in
            guard let self = self else { return }
            self.playerManager?.seek(by: 10)
            self.playerDidSeek()
            resetControlsHideTimer()
        }
    }
    
    /// 재생 위치 슬라이더 값 변경 핸들러
    @objc func sliderValueChanged(_ slider: UISlider) {
        guard let player = playerManager?.player,
              let duration = player.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(slider.value) * totalSeconds
        let seekTime = CMTime(value: Int64(value), timescale: 1)
        player.seek(to: seekTime)
        resetControlsHideTimer()
    }
    
    /// 컨트롤 자동 숨김 타이머 재설정
    func resetControlsHideTimer() {
        if isPlaying {
            scheduleControlsHide()
        }
    }
    
    func playerDidSeek() {
        viewModel?.pauseWatching()
        
        Task { [weak self] in
            guard let self = self else { return }
            try? await Task.sleep(nanoseconds: 500_000_000)
            if self.isPlaying {
                self.viewModel?.startWatching()
            }
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
    
    // MARK: - App Background Handling
    
    @objc func appDidEnterBackground() {
        playPauseButtonTapped()
        viewModel?.pauseWatching()
    }
    
    // MARK: - PlayerGestureDelegate
    /// 단일 탭: 컨트롤(재생버튼, 시커 등) show/hide 토글
    func didToggleControls() {
        areControlsVisible.toggle()
        let alpha: CGFloat = areControlsVisible ? 1.0 : 0.0

        UIView.animate(withDuration: 0.3) {
            self.playbackControlsStack.alpha = alpha
            self.seekerStack.alpha = alpha
            self.fullscreenButton.alpha = alpha
            self.dismissButton.alpha = alpha
        }

        if areControlsVisible && isPlaying {
            scheduleControlsHide()
        } else {
            cancelControlsHide()
        }
    }
    
    /// 더블 탭: 왼쪽/오른쪽 10초 skip
    /// - Parameter recognizer: UITapGestureRecognizer
    func didSeek(by seconds: Double) {
        hideControls()
        
        // 아이콘 생성
        let iconName = seconds < 0 ? "backward.fill" : "forward.fill"
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.alpha = 0.0
        iconView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)

        // 중앙 위치 계산 (좌/우) - videoContainerView 기준
        let containerBounds = videoContainerView.bounds
        let centerY = containerBounds.midY
        let centerX = seconds < 0 ? containerBounds.width * 0.25 : containerBounds.width * 0.75
        iconView.center = CGPoint(x: centerX, y: centerY)

        videoContainerView.insertSubview(iconView, belowSubview: controlsOverlayView)

        // 애니메이션 처리
        UIView.animate(withDuration: 0.15, animations: {
            iconView.alpha = 1.0
            iconView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.2, options: [], animations: {
                iconView.alpha = 0.0
                iconView.transform = .identity
            }, completion: { _ in
                iconView.removeFromSuperview()
            })
        }

        playerManager?.seek(by: seconds)
        
        resetControlsHideTimer()
    }
    
    /// 길게 누르면 2배속, 떼면 1배속 (재생 중일 때만 적용)
    func didStartFastForward() {
        // 재생 중인 플레이어에만 적용
        guard let playerManager, let avPlayer = playerManager.player, avPlayer.rate != 0 else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()

        avPlayer.rate = 2.0
        rateTwoView.isHidden = false
    }
    
    func didStopFastForward() {
        // 재생 중인 플레이어에만 적용
        guard let playerManager, let avPlayer = playerManager.player, avPlayer.rate != 0 else { return }
        avPlayer.rate = 1.0
        rateTwoView.isHidden = true
    }
    
    @objc func requestEnterFullscreen() {
        // Swipe-up
    }
    
    func requestDismissToHome() {
        assertionFailure("Must override requestEnterFullscreen in subclass")
    }

    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - PlayerManagerDelegate

extension BasePlayerViewController: PlayerManagerDelegate {
    func playerDidUpdateTime(current: String, total: String, progress: Float) {
        currentTimeLabel.text = current
        totalDurationLabel.text = total
        progressSlider.value = progress
    }
    
    /// 영상 재생이 끝났을 때 호출됨 (자동 초기화)
    func playerDidFinishPlaying() {
        isPlaying = false
        viewModel?.pauseWatching()
        let playImage = UIImage(systemName: "arrow.clockwise", withConfiguration: symbolConfig)
        playPauseButton.setImage(playImage, for: .normal)
        areControlsVisible = true
        cancelControlsHide()
        
        UIView.animate(withDuration: 0.3) {
            self.playbackControlsStack.alpha = 1.0
            self.seekerStack.alpha = 1.0
            self.fullscreenButton.alpha = 1.0
            self.dismissButton.alpha = 1.0
        }
    }
}
