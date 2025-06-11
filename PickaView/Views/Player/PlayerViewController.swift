//
//  PlayerViewController.swift
//  PickaView
//
//  Created by junil on 6/9/25.
//

import UIKit
import AVKit

protocol FullscreenPlayerViewControllerDelegate: AnyObject {
    func fullscreenPlayerDidDismiss(playerLayer: AVPlayerLayer?)
}

class PlayerViewController: UIViewController, FullscreenPlayerViewControllerDelegate {
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    let videoContainerView = UIView()
    let controlsView = PlayerControlsView()

    var timeObserverToken: Any?
    var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        addPlayerObservers()
    }

    func setupUI() {
        view.backgroundColor = .systemBackground
        videoContainerView.backgroundColor = .black
        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        controlsView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(videoContainerView)
        videoContainerView.addSubview(controlsView)

        NSLayoutConstraint.activate([
            videoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9.0/16.0),

            controlsView.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            controlsView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            controlsView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor)
        ])

        if let playerLayer = playerLayer {
            playerLayer.removeFromSuperlayer()
            videoContainerView.layer.insertSublayer(playerLayer, at: 0)
            playerLayer.frame = videoContainerView.bounds
        }
    }

    func setupActions() {
        controlsView.playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        controlsView.backwardButton.addTarget(self, action: #selector(backwardTapped), for: .touchUpInside)
        controlsView.forwardButton.addTarget(self, action: #selector(forwardTapped), for: .touchUpInside)
        controlsView.progressSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
    }

    // MARK: - 핸들러
    @objc func playPauseTapped() {
        guard let player = player else { return }
        isPlaying.toggle()
        if isPlaying {
            player.play()
            controlsView.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            player.pause()
            controlsView.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }

    @objc func backwardTapped() {
        seek(by: -10)
    }

    @objc func forwardTapped() {
        seek(by: 10)
    }

    @objc func sliderChanged(_ slider: UISlider) {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(slider.value) * totalSeconds
        let seekTime = CMTime(seconds: value, preferredTimescale: 600)
        player.seek(to: seekTime)
    }

    func seek(by seconds: Double) {
        guard let player = player else { return }
        let current = player.currentTime()
        let total = player.currentItem?.duration ?? .zero
        var newTime = CMTimeGetSeconds(current) + seconds
        let durationSeconds = CMTimeGetSeconds(total)
        if newTime < 0 { newTime = 0 }
        if durationSeconds > 0 && newTime > durationSeconds { newTime = durationSeconds }
        let time = CMTime(seconds: newTime, preferredTimescale: 600)
        player.seek(to: time)
    }

    func addPlayerObservers() {
        guard let player = self.player else { return }
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: .main) { [weak self] time in
            self?.updateTimeLabels()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }

    func updateTimeLabels() {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        let currentTime = player.currentTime()
        let totalSeconds = CMTimeGetSeconds(duration)
        let currentSeconds = CMTimeGetSeconds(currentTime)
        controlsView.currentTimeLabel.text = timeString(from: currentSeconds)
        controlsView.totalDurationLabel.text = timeString(from: totalSeconds)
        if totalSeconds > 0 {
            controlsView.progressSlider.value = Float(currentSeconds / totalSeconds)
        } else {
            controlsView.progressSlider.value = 0
        }
    }

    @objc func playerDidFinishPlaying() {
        isPlaying = false
        controlsView.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        controlsView.progressSlider.value = 0
        controlsView.currentTimeLabel.text = "00:00"
    }

    func timeString(from seconds: Double) -> String {
        guard seconds.isFinite else { return "00:00" }
        let min = Int(seconds / 60)
        let sec = Int(seconds) % 60
        if seconds >= 3600 {
            let hour = Int(seconds / 3600)
            return String(format: "%d:%02d:%02d", hour, min % 60, sec)
        } else {
            return String(format: "%02d:%02d", min, sec)
        }
    }

    // 전체화면 진입
    func presentFullscreen() {
        let fullscreenVC = FullscreenPlayerViewController()
        fullscreenVC.player = self.player
        fullscreenVC.playerLayer = self.playerLayer
        fullscreenVC.delegate = self
        fullscreenVC.modalPresentationStyle = .fullScreen
        present(fullscreenVC, animated: true)
    }

    func fullscreenPlayerDidDismiss(playerLayer: AVPlayerLayer?) {
        guard let playerLayer = playerLayer else { return }
        playerLayer.removeFromSuperlayer()
        videoContainerView.layer.insertSublayer(playerLayer, at: 0)
        playerLayer.frame = videoContainerView.bounds
    }

    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        NotificationCenter.default.removeObserver(self)
    }
}
