//
//  PlayerViewController+Player.swift
//  PickaView
//
//  Created by junil on 6/10/25.
//

import AVKit

extension PlayerViewController {
    /// 비디오 플레이어를 초기화하고, AVPlayerLayer를 준비
    ///
    /// - Note: 영상 URL이 잘못된 경우 에러 메시지를 출력
    func setupPlayer() {
        let urlString = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
        guard let videoURL = URL(string: urlString) else {
            print("Error: Invalid URL string.")
            return
        }

        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)

        guard let playerLayer = self.playerLayer else { return }
        playerLayer.videoGravity = .resizeAspect
        videoContainerView.layer.insertSublayer(playerLayer, at: 0)
    }

    /// 플레이어 상태와 시간 업데이트, 종료 이벤트에 대한 옵저버를 등록
    ///
    /// - Note: 타임 옵저버와 Notification, KVO를 모두 등록
    func addPlayerObservers() {
        guard let player = self.player else { return }

        // 1초마다 플레이어 시간 업데이트 콜백 등록
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.updatePlayerTime()
        }

        // 영상이 끝났을 때 알림 등록
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)

        // 플레이어 준비 상태를 KVO로 관찰
        player.currentItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
    }

    /// KVO로부터 플레이어 상태 변화를 감지해 처리
    ///
    /// - Parameters:
    ///   - keyPath: 변화 감지할 키 경로
    ///   - object: 변화가 발생한 객체
    ///   - change: 변화 정보
    ///   - context: 컨텍스트 포인터
    ///
    /// - Note: 플레이어 준비 완료시 타이머/타임라벨 업데이트를 시작
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

    /// 영상의 현재 위치를 원하는 만큼 앞뒤로 이동
    ///
    /// - Parameter seconds: 이동할 초(+, - 가능)
    func seek(by seconds: Double) {
        guard let player = self.player else { return }

        let currentTime = player.currentTime()
        let newTime = CMTimeGetSeconds(currentTime) + seconds
        let time = CMTime(value: Int64(newTime), timescale: 1)
        player.seek(to: time)
        resetControlsHideTimer()
    }

    /// 플레이어의 현재 시간/슬라이더/라벨을 갱신
    ///
    /// - Note: 재생 시간이 변할 때마다 호출되며, 시간 라벨과 슬라이더 위치를 동기화
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
