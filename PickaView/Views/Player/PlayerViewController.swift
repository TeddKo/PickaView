////
////  PlayerViewController.swift
////  PickaView
////
////  Created by junil on 6/9/25.
////
//
//import UIKit
//import AVKit
//
//protocol PlayerViewControllerDelegate: AnyObject {
//    func didDismissFullscreen()
//}
//
///// 영상 재생 및 플레이어 UI를 담당하는 뷰 컨트롤러
//class PlayerViewController: UIViewController, PlayerViewControllerDelegate {
//
//    // MARK: - Properties
//
//    /// AVPlayer 인스턴스 (영상 재생 담당)
//    var player: AVPlayer?
//
//    /// 영상 출력을 위한 AVPlayerLayer
//    var playerLayer: AVPlayerLayer?
//
//    /// 재생 시간 업데이트 관찰 토큰
//    var timeObserverToken: Any?
//
//    /// 현재 재생 여부
//    var isPlaying = false
//
//    /// 컨트롤(버튼 등) 표시 여부
//    var areControlsVisible = true
//
//    /// 컨트롤 자동 숨김용 타이머
//    var controlsHideTimer: Timer?
//
//    /// 세로/가로 전환 시 사용되는 오토레이아웃 제약
//    var portraitConstraints: [NSLayoutConstraint] = []
//    var landscapeConstraints: [NSLayoutConstraint] = []
//
//    // 프로퍼티 추가
//    var isFullscreenMode: Bool = false
//    weak var delegate: PlayerViewControllerDelegate?
//
//    /// 하단 재생/이동 버튼 스택
//    lazy var playbackControlsStack: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [backwardButton, playPauseButton, forwardButton])
//        stackView.axis = .horizontal
//        stackView.alignment = .center
//        stackView.distribution = .equalSpacing
//        stackView.spacing = 40
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//
//    /// 시간/슬라이더 스택
//    lazy var seekerStack: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [currentTimeLabel, progressSlider, totalDurationLabel])
//        stackView.spacing = 8
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//
//    /// 영상 표시용 컨테이너 뷰
//    let videoContainerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .black
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    /// 컨트롤 오버레이 뷰
//    let controlsOverlayView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    /// 재생/일시정지 버튼
//    lazy var playPauseButton: UIButton = {
//        let button = createButton(systemName: "play.fill")
//        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
//        return button
//    }()
//
//    /// 10초 뒤로 버튼
//    lazy var backwardButton: UIButton = {
//        let button = createButton(systemName: "10.arrow.trianglehead.counterclockwise", useSmallConfig: true)
//        button.addTarget(self, action: #selector(backwardButtonTapped), for: .touchUpInside)
//        return button
//    }()
//
//    /// 10초 앞으로 버튼
//    lazy var forwardButton: UIButton = {
//        let button = createButton(systemName: "10.arrow.trianglehead.clockwise", useSmallConfig: true)
//        button.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
//        return button
//    }()
//
//    /// 현재 재생 시간 표시 라벨
//    lazy var currentTimeLabel: UILabel = {
//        createTimeLabel(text: "00:00")
//    }()
//
//    /// 총 영상 길이 표시 라벨
//    lazy var totalDurationLabel: UILabel = {
//        createTimeLabel(text: "00:00")
//    }()
//
//    /// 재생 위치 조정 슬라이더
//    lazy var progressSlider: UISlider = {
//        let slider = UISlider()
//        slider.minimumValue = 0
//        slider.tintColor = .red
//        slider.thumbTintColor = .red
//        slider.translatesAutoresizingMaskIntoConstraints = false
//        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
//        return slider
//    }()
//
//    /// (선택) 추가 스크롤 컨테이너
//    let contentScrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        return scrollView
//    }()
//
//    // MARK: - View Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//
//        setupPlayer()
//        setupUI()
//        setPlayPauseImage(isPlaying: false)
//        setupGestures()
//        addPlayerObservers()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        updateConstraintsForOrientation()
//    }
//
//    func didDismissFullscreen() {
//        setOrientation(to: .portrait)
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        if isFullscreenMode {
//            setOrientation(to: .portrait)
//            delegate?.didDismissFullscreen()
//        }
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        playerLayer?.frame = videoContainerView.bounds
//    }
//
//    /// 지원하는 화면 방향
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return isFullscreenMode ? .landscape : .all
//    }
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return isFullscreenMode ? .landscapeRight : .portrait
//    }
//
//    /// 자동 회전 지원 여부
//    override var shouldAutorotate: Bool {
//        return true
//    }
//
//    /// 화면 회전 시 제약 업데이트
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//
//        coordinator.animate(alongsideTransition: { _ in
//            self.updateConstraintsForOrientation()
//            self.view.layoutIfNeeded()
//        })
//    }
//
//    // MARK: - Actions
//
//    /// 재생/일시정지 버튼 탭 시 호출
//    @objc func playPauseButtonTapped() {
//        guard let player = self.player else { return }
//
//        animateButtonTap(playPauseButton) {
//            self.isPlaying.toggle()
//            self.setPlayPauseImage(isPlaying: self.isPlaying)
//
//            if self.isPlaying {
//                player.play()
//                self.scheduleControlsHide()
//            } else {
//                player.pause()
//                self.cancelControlsHide()
//            }
//        }
//    }
//
//    /// 버튼을 일정 각도로 돌렸다가 복귀하는 애니메이션
//    /// - Parameters:
//    ///   - button: 애니메이션할 버튼
//    ///   - clockwise: 시계 방향 여부
//    ///   - completion: 완료 핸들러
//    func animateButtonSpin(_ button: UIButton, clockwise: Bool, completion: (() -> Void)? = nil) {
//        button.layer.removeAllAnimations()
//        let angle: CGFloat = clockwise ? -CGFloat.pi / 2 : CGFloat.pi / 2
//
//        UIView.animateKeyframes(withDuration: 0.25, delay: 0, options: [], animations: {
//            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
//                button.transform = CGAffineTransform(rotationAngle: angle).scaledBy(x: 0.85, y: 0.85)
//            }
//            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
//                button.transform = .identity
//            }
//        }, completion: { _ in
//            completion?()
//        })
//    }
//
//    /// 뒤로가기(10초) 버튼 탭 시 호출
//    @objc func backwardButtonTapped() {
//        animateButtonSpin(backwardButton, clockwise: true) {
//            self.seek(by: -10)
//        }
//    }
//
//    /// 앞으로(10초) 버튼 탭 시 호출
//    @objc func forwardButtonTapped() {
//        animateButtonSpin(forwardButton, clockwise: false) {
//            self.seek(by: 10)
//        }
//    }
//
//    /// 슬라이더 값 변경 시 호출 (영상 위치 이동)
//    @objc func sliderValueChanged(_ slider: UISlider) {
//        guard let player = self.player, let duration = player.currentItem?.duration else { return }
//
//        let totalSeconds = CMTimeGetSeconds(duration)
//        let value = Float64(slider.value) * totalSeconds
//        let seekTime = CMTime(value: Int64(value), timescale: 1)
//        player.seek(to: seekTime)
//        resetControlsHideTimer()
//    }
//
//    /// 영상 재생 완료 시 호출
//    @objc func playerDidFinishPlaying() {
//        guard let player = self.player else { return }
//
//        isPlaying = false
//        let playImage = UIImage(systemName: "arrow.clockwise")
//        playPauseButton.setImage(playImage, for: .normal)
//        player.seek(to: .zero)
//        progressSlider.value = 0
//        currentTimeLabel.text = "00:00"
//    }
//
//    /// 화면 터치 등으로 컨트롤러 표시/숨김 토글
//    @objc func toggleControlsVisibility() {
//        areControlsVisible.toggle()
//        let alpha: CGFloat = areControlsVisible ? 1.0 : 0.0
//
//        UIView.animate(withDuration: 0.3) {
//            self.playbackControlsStack.alpha = alpha
//            self.seekerStack.alpha = alpha
//        }
//
//        if areControlsVisible && isPlaying {
//            scheduleControlsHide()
//        } else {
//            cancelControlsHide()
//        }
//    }
//
//    /// 컨트롤 자동 숨김 예약 (3초 후)
//    func scheduleControlsHide() {
//        cancelControlsHide()
//        controlsHideTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
//    }
//
//    /// 컨트롤 숨김 처리
//    @objc func hideControls() {
//        areControlsVisible = false
//        UIView.animate(withDuration: 0.3) {
//            self.playbackControlsStack.alpha = 0.0
//            self.seekerStack.alpha = 0.0
//        }
//    }
//
//    /// 컨트롤 자동 숨김 취소
//    func cancelControlsHide() {
//        controlsHideTimer?.invalidate()
//        controlsHideTimer = nil
//    }
//
//    /// 재생 중 터치/이동 시 타이머 리셋
//    func resetControlsHideTimer() {
//        if isPlaying {
//            scheduleControlsHide()
//        }
//    }
//
//    // MARK: - Deinit
//
//    /// 뷰 컨트롤러 해제 시 옵저버 및 타이머 해제
//    deinit {
//        if let token = timeObserverToken {
//            player?.removeTimeObserver(token)
//            timeObserverToken = nil
//        }
//        if let player = player {
//            player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
//        }
//        NotificationCenter.default.removeObserver(self)
//        print("PlayerViewController deinitialized")
//    }
//}

import UIKit
import AVKit

protocol PlayerViewControllerDelegate: AnyObject {
    func didDismissFullscreen()
}

/// 영상 재생 및 플레이어 UI를 담당하는 뷰 컨트롤러
class PlayerViewController: UIViewController, PlayerViewControllerDelegate {

    // MARK: - Properties

    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var timeObserverToken: Any?
    var isPlaying = false
    var areControlsVisible = true
    var controlsHideTimer: Timer?
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    var isFullscreenMode: Bool = false
    weak var delegate: PlayerViewControllerDelegate?

    lazy var playbackControlsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backwardButton, playPauseButton, forwardButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 40
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var seekerStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [currentTimeLabel, progressSlider, totalDurationLabel])
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    let videoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let controlsOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var playPauseButton: UIButton = {
        let button = createButton(systemName: "play.fill")
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var backwardButton: UIButton = {
        let button = createButton(systemName: "10.arrow.trianglehead.counterclockwise", useSmallConfig: true)
        button.addTarget(self, action: #selector(backwardButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var forwardButton: UIButton = {
        let button = createButton(systemName: "10.arrow.trianglehead.clockwise", useSmallConfig: true)
        button.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var currentTimeLabel: UILabel = {
        createTimeLabel(text: "00:00")
    }()

    lazy var totalDurationLabel: UILabel = {
        createTimeLabel(text: "00:00")
    }()

    lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.tintColor = .red
        slider.thumbTintColor = .red
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()

    let contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupPlayer()
        setupUI()
        setPlayPauseImage(isPlaying: false)
        setupGestures()
        addPlayerObservers()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    func scheduleControlsHide() {
        cancelControlsHide()
        controlsHideTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }

    func cancelControlsHide() {
        controlsHideTimer?.invalidate()
        controlsHideTimer = nil
    }

    @objc func hideControls() {
        areControlsVisible = false
        UIView.animate(withDuration: 0.3) {
            self.playbackControlsStack.alpha = 0.0
            self.seekerStack.alpha = 0.0
        }
    }

    @objc func playPauseButtonTapped() {
        guard let player = self.player else { return }

        animateButtonTap(playPauseButton) {
            self.isPlaying.toggle()
            self.setPlayPauseImage(isPlaying: self.isPlaying)

            if self.isPlaying {
                player.play()
                self.scheduleControlsHide()
            } else {
                player.pause()
                self.cancelControlsHide()
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

    @objc func backwardButtonTapped() {
        animateButtonSpin(backwardButton, clockwise: true) {
            self.seek(by: -10)
        }
    }

    @objc func forwardButtonTapped() {
        animateButtonSpin(forwardButton, clockwise: false) {
            self.seek(by: 10)
        }
    }

    @objc func sliderValueChanged(_ slider: UISlider) {
        guard let player = self.player, let duration = player.currentItem?.duration else { return }

        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(slider.value) * totalSeconds
        let seekTime = CMTime(value: Int64(value), timescale: 1)
        player.seek(to: seekTime)
        resetControlsHideTimer()
    }

    @objc func playerDidFinishPlaying() {
        guard let player = self.player else { return }

        isPlaying = false
        let playImage = UIImage(systemName: "arrow.clockwise")
        playPauseButton.setImage(playImage, for: .normal)
        player.seek(to: .zero)
        progressSlider.value = 0
        currentTimeLabel.text = "00:00"
    }

    func resetControlsHideTimer() {
        if isPlaying {
            scheduleControlsHide()
        }
    }
    // -------------------------


    @objc func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation
        // 가로면 전체화면 진입, 세로면 해제 (기기 직접 돌렸을 때도 동작)
        if (orientation == .landscapeLeft || orientation == .landscapeRight), !isFullscreenMode {
            presentFullscreen()
        } else if orientation == .portrait, isFullscreenMode {
            // 전체화면에서 FullscreenPlayerViewController가 알아서 내려감
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConstraintsForOrientation()
    }

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

    // PlayerViewController.swift
    func didDismissFullscreen() {
        print(">> 복귀: didDismissFullscreen")  // << 이거 추가
        isFullscreenMode = false

        // ✅ 오버레이/레이어 복귀 (반드시!)
        if let playerLayer = self.playerLayer {
            playerLayer.removeFromSuperlayer()
            videoContainerView.layer.insertSublayer(playerLayer, at: 0)
            playerLayer.frame = videoContainerView.bounds
        }
        controlsOverlayView.removeFromSuperview()
        videoContainerView.addSubview(controlsOverlayView)
        NSLayoutConstraint.deactivate(controlsOverlayView.constraints)
        controlsOverlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlsOverlayView.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            controlsOverlayView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            controlsOverlayView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            controlsOverlayView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor)
        ])
        view.setNeedsLayout()
        view.layoutIfNeeded()
        setupGestures()

        // ✅ orientation portrait 복원 (구버전 호환)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.didDismissFullscreen()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return isFullscreenMode ? .landscape : .all
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return isFullscreenMode ? .landscapeRight : .portrait
    }
    override var shouldAutorotate: Bool { true }

    // MARK: - 전체화면 진입 함수
    // PlayerViewController.swift 안에서
    func presentFullscreen() {
        print(">> 진입: presentFullscreen")  // << 이거 추가
        let fullscreenVC = FullscreenPlayerViewController()
        fullscreenVC.modalPresentationStyle = .fullScreen

        // ✅ 반드시 연결
        fullscreenVC.playerLayer = self.playerLayer
        fullscreenVC.controlsOverlayView = self.controlsOverlayView
        fullscreenVC.delegate = self  // <-- delegate 연결!
        isFullscreenMode = true

        present(fullscreenVC, animated: true) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if #available(iOS 16.0, *) {
                    if let scene = fullscreenVC.view.window?.windowScene {
                        scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight), errorHandler: nil)
                    }
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                    UIViewController.attemptRotationToDeviceOrientation()
                }
            }
        }
    }

    deinit {
        if let token = timeObserverToken { player?.removeTimeObserver(token) }
        NotificationCenter.default.removeObserver(self)
    }
}
