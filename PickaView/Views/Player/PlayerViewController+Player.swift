//
//  PlayerViewController+Player.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//

import AVKit

/// PlayerViewController의 AVPlayer 관련 확장
extension PlayerViewController {

    // MARK: - Player 초기화

    /// AVPlayer 및 AVPlayerLayer를 초기화하고 기본 영상으로 세팅합니다.
    func setupPlayer(with urlString: String) {
        guard let videoURL = URL(string: urlString) else {
            print("Error: Invalid URL string.")
            return
        }

        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = videoContainerView.bounds

        if let playerLayer = playerLayer {
            videoContainerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() } // 기존 레이어 제거
            videoContainerView.layer.insertSublayer(playerLayer, at: 0)
        }

        player?.play()
    }


    // MARK: - Player Observer 관리

    /// 재생 시간 관찰 및 상태 변화, 종료 알림 옵저버 추가
    func addPlayerObservers() {
        guard let player = self.player else { return }

        // 1초마다 현재 시간 갱신
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] _ in
            self?.updatePlayerTime()
        }

        // 재생 종료 알림
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )

        // 플레이어 준비 상태 옵저빙
        player.currentItem?.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.new],
            context: nil
        )
    }

    /// AVPlayerItem의 status 옵저빙 결과 처리
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
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

    // MARK: - Player Seek / Time

    /// 영상 재생 위치를 원하는 초 만큼 이동합니다.
    /// - Parameter seconds: 이동할 시간(초, 양수: 앞으로, 음수: 뒤로)
    func seek(by seconds: Double) {
        guard let player = self.player else { return }

        let currentTime = player.currentTime()
        let newTime = CMTimeGetSeconds(currentTime) + seconds
        let time = CMTime(value: Int64(newTime), timescale: 1)
        player.seek(to: time)
        resetControlsHideTimer()
    }

    /// 현재 재생 위치와 총 길이를 라벨/슬라이더에 반영합니다.
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
