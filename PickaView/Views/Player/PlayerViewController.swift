//
//  PlayerViewController.swift
//  PickaView
//
//  Created by junil on 6/9/25.
//

import UIKit
import AVKit

class PlayerViewController: UIViewController {

    // MARK: - Properties
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var timeObserverToken: Any?

    var isPlaying = false
    var areControlsVisible = true
    var controlsHideTimer: Timer?

    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []

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

    // MARK: - UI Components
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

    // 처음 초기화할 때도!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupPlayer()
        setupUI()
        setPlayPauseImage(isPlaying: false) // ← 추가
        setupGestures()
        addPlayerObservers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }

    // MARK: - Rotation Handling
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.updateConstraintsForOrientation()
            self.view.layoutIfNeeded()
        })
    }

    @objc func playPauseButtonTapped() {
        guard let player = self.player else { return }

        animateButtonTap(playPauseButton) {
            self.isPlaying.toggle()
            self.setPlayPauseImage(isPlaying: self.isPlaying) // ← 이걸로!

            if self.isPlaying {
                player.play()
                self.scheduleControlsHide()
            } else {
                player.pause()
                self.cancelControlsHide()
            }
        }
    }

    func animateButtonSpin(_ button: UIButton, completion: (() -> Void)? = nil) {
        UIView.animateKeyframes(withDuration: 0.45, delay: 0, options: [.calculationModeLinear], animations: {
            // 1단계: 살짝 줄이면서(눌림) + 0~180도 회전
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
                button.transform = CGAffineTransform(rotationAngle: .pi).scaledBy(x: 0.85, y: 0.85)
            }
            // 2단계: 다시 원래대로 (360도 회전 + 원래 크기)
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                button.transform = .identity
            }
        }, completion: { _ in
            completion?()
        })
    }

    @objc func backwardButtonTapped() {
        animateButtonSpin(backwardButton) {
            self.seek(by: -10)
        }
    }

    @objc func forwardButtonTapped() {
        animateButtonSpin(forwardButton) {
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

    // MARK: - Controls Visibility
    @objc func toggleControlsVisibility() {
        areControlsVisible.toggle()
        let alpha: CGFloat = areControlsVisible ? 1.0 : 0.0

        UIView.animate(withDuration: 0.3) {
            // ✅ FIX: `alpha`를 조절할 대상을 StackView로 명확히 지정
            self.playbackControlsStack.alpha = alpha
            self.seekerStack.alpha = alpha
        }

        if areControlsVisible && isPlaying {
            scheduleControlsHide()
        } else {
            cancelControlsHide()
        }
    }

    func scheduleControlsHide() {
        cancelControlsHide()
        controlsHideTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }

    @objc func hideControls() {
        areControlsVisible = false
        UIView.animate(withDuration: 0.3) {
            self.playbackControlsStack.alpha = 0.0
            self.seekerStack.alpha = 0.0
        }
    }

    func cancelControlsHide() {
        controlsHideTimer?.invalidate()
        controlsHideTimer = nil
    }

    func resetControlsHideTimer() {
        if isPlaying {
            scheduleControlsHide()
        }
    }

    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        if let player = player {
            player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        }
        NotificationCenter.default.removeObserver(self)
        print("PlayerViewController deinitialized")
    }
}
