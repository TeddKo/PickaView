//
//  PlayerViewController+Player.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//

import AVKit

/// AVPlayer 관련 기능 확장
extension PlayerViewController {

    /// AVPlayer와 AVPlayerLayer를 초기화하고 videoContainerView에 추가
    func setupPlayer() {
        let urlString = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
        guard let videoURL = URL(string: urlString) else {
            print("Error: Invalid URL string.")
            return
        }

        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect

        if let playerLayer = playerLayer {
            videoContainerView.layer.insertSublayer(playerLayer, at: 0)
        }
    }

    /// AVPlayer 상태 및 시간 관찰자, Notification 등록
    func addPlayerObservers() {
        guard let player = self.player else { return }

        // 1초 간격으로 재생 시간 업데이트
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] _ in
            self?.updatePlayerTime()
        }

        // 재생 종료 알림 등록
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)

        // AVPlayerItem 상태 KVO 등록
        player.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
    }

    /// AVPlayerItem의 상태 변화 관찰 처리
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

    /// 영상의 재생 위치를 seconds 만큼 이동
    /// - Parameter seconds: 이동할 초 단위 값 (음수: 뒤로, 양수: 앞으로)
    func seek(by seconds: Double) {
        guard let player = self.player else { return }

        let currentTime = player.currentTime()
        let newTime = CMTimeGetSeconds(currentTime) + seconds
        let time = CMTime(value: Int64(newTime), timescale: 1)
        player.seek(to: time)
        resetControlsHideTimer()
    }

    /// 현재 재생 시간, 전체 길이, 슬라이더를 UI에 업데이트
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
