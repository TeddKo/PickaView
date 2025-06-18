//
//  PlayerManager.swift
//  PickaView
//
//  Created by 장지현 on 6/17/25.
//

import AVKit

protocol PlayerManagerDelegate: AnyObject {
    func playerDidUpdateTime(current: String, total: String, progress: Float)
    func playerDidFinishPlaying()
    func playerDidBecomeReadyToPlay()
    func playerDidSeek()
}

/// PlayerManager는 영상 재생의 핵심 컨트롤러
/// AVPlayer 설정, 시간 이동, 상태 관찰, 시청 시간 기록 등을 담당
final class PlayerManager: NSObject {
     
    /// AVPlayer 인스턴스 (영상 재생)
    private(set) var player: AVPlayer?
    
    /// 영상 레이어 (재생 화면용)
    private(set) var playerLayer: AVPlayerLayer?
    
    /// 재생 시간 관찰 토큰 (clean-up용)
    private var timeObserverToken: Any?
    
    private var isObservingStatus = false
    
    weak var delegate: PlayerManagerDelegate?
    
    var videoContainerView: UIView?

    // MARK: - Player 초기화

    /// AVPlayer 및 AVPlayerLayer를 초기화하고 영상 세팅
    func setupPlayer(with urlString: String) {
        guard let videoURL = URL(string: urlString) else { return }

        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = videoContainerView?.bounds ?? .zero

        if let playerLayer = playerLayer {
            if playerLayer.superlayer != nil {
                playerLayer.removeFromSuperlayer()
            }
            videoContainerView?.layer.insertSublayer(playerLayer, at: 0)
        }

        addPlayerObservers()
        player?.play()
    }
    
    /// 플레이어 레이어를 새로운 bounds로 갱신
    func updatePlayerLayerFrame(to bounds: CGRect) {
        playerLayer?.frame = bounds
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

        if isObservingStatus {
            player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: nil)
            isObservingStatus = false
        }

        // 플레이어 준비 상태 옵저빙
        player.currentItem?.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.new],
            context: nil
        )
        isObservingStatus = true
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
                delegate?.playerDidBecomeReadyToPlay()
                updatePlayerTime()
            }
        }
    }

    // MARK: - Player Seek / Time

    /// 영상 재생 위치를 원하는 초 만큼 이동
    /// - Parameter seconds: 이동할 시간(초, 양수: 앞으로, 음수: 뒤로)
    func seek(by seconds: Double) {
        guard let player = self.player else { return }

        let currentTime = player.currentTime()
        let newTime = CMTimeGetSeconds(currentTime) + seconds
        let time = CMTime(value: Int64(newTime), timescale: 1)
        player.seek(to: time)
    }

    /// 현재 재생 위치와 총 길이를 라벨/슬라이더에 반영
    func updatePlayerTime() {
        guard let player = self.player,
              let currentTime = player.currentItem?.currentTime(),
              let duration = player.currentItem?.duration else { return }

        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        let durationInSeconds = CMTimeGetSeconds(duration)

        if durationInSeconds.isFinite && durationInSeconds > 0 {
            let progress = Float(currentTimeInSeconds / durationInSeconds)
            let current = currentTime.toTimeString()
            let total = duration.toTimeString()
            delegate?.playerDidUpdateTime(current: current, total: total, progress: progress)
        }
    }

    // MARK: - Notification Handling

    /// 영상이 끝까지 재생되었을 때 호출되는 메서드
    @objc private func playerDidFinishPlaying() {
        delegate?.playerDidFinishPlaying()
    }
    
    // MARK: - Deinit
    
    deinit {
        // 타임 옵저버 해제
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        // Notification and KVO 옵저버 해제
        NotificationCenter.default.removeObserver(self)
        if isObservingStatus {
            player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            isObservingStatus = false
        }
    }
}
