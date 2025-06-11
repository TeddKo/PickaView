//
//  PlayerViewController+Player.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//

import AVKit

extension PlayerViewController {

    func setupPlayer() {
        let urlString = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
        guard let videoURL = URL(string: urlString) else {
            print("Error: Invalid URL string.")
            return
        }

        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect   // ✅ Optional로 안전 접근

        if let playerLayer = playerLayer {
            videoContainerView.layer.insertSublayer(playerLayer, at: 0) // ✅ Optional 해제 후 전달
        }
    }

    // MARK: - Player Observers
    func addPlayerObservers() {
        guard let player = self.player else { return }

        // 1초마다 시간 업데이트
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] _ in
            self?.updatePlayerTime()
        }

        // 비디오 재생이 끝나면 호출
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)

        // 비디오 로드 상태 관찰
        player.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status),
           let statusValue = change?[.newKey] as? Int,
           let status = AVPlayerItem.Status(rawValue: statusValue) {
            if status == .readyToPlay {
                if isPlaying {
                    scheduleControlsHide()
                }
                updatePlayerTime()
            }
        }
    }

    // MARK: - Player Helpers
    func seek(by seconds: Double) {
        guard let player = self.player else { return }

        let currentTime = player.currentTime()
        let newTime = CMTimeGetSeconds(currentTime) + seconds
        let time = CMTime(value: Int64(newTime), timescale: 1)
        player.seek(to: time)
        resetControlsHideTimer()
    }

    func updatePlayerTime() {
        guard let player = self.player,
              let currentTime = player.currentItem?.currentTime(),
              let duration = player.currentItem?.duration else { return }

        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        let durationInSeconds = CMTimeGetSeconds(duration)

        if durationInSeconds.isFinite && durationInSeconds > 0 {
            progressSlider.value = Float(currentTimeInSeconds / durationInSeconds)
            currentTimeLabel.text = currentTime.toTimeString()
            totalDurationLabel.text = duration.toTimeString()
        }
    }
}
