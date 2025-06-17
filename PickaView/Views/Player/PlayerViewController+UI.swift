//
//  PlayerViewController+UI.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//

import UIKit

/// PlayerViewController의 UI 및 레이아웃 확장
extension PlayerViewController {

    // MARK: - Symbol Config

    /// 기본 아이콘 크기 설정 (플레이/정지 버튼)
    var symbolConfig: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 36, weight: .regular, scale: .large)
    }

    /// 작은 아이콘 크기 설정 (앞/뒤 버튼)
    var smallSymbolConfig: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 26, weight: .regular, scale: .medium)
    }

    // MARK: - UI 초기 세팅

    /// UI 컴포넌트 계층 및 오토레이아웃 세팅
    func setupUI() {
        videoPlayerView.addSubview(videoContainerView)

        videoContainerView.addSubview(controlsOverlayView)
        controlsOverlayView.addSubview(playbackControlsStack)
        controlsOverlayView.addSubview(seekerStack)
        controlsOverlayView.addSubview(fullscreenButton)
        controlsOverlayView.addSubview(dismissButton)
  
        videoContainerView.addSubview(rateTwoView)
        videoContainerView.insertSubview(rateTwoView, belowSubview: controlsOverlayView)

        rateTwoView.layer.cornerRadius = 8

        // 세로/가로 레이아웃 제약 정의
        portraitConstraints = [
            videoContainerView.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor),
            videoContainerView.topAnchor.constraint(equalTo: videoPlayerView.topAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: videoPlayerView.bottomAnchor),
        ]

        landscapeConstraints = [
            videoContainerView.leadingAnchor.constraint(equalTo: videoPlayerView.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: videoPlayerView.trailingAnchor),
            videoContainerView.topAnchor.constraint(equalTo: videoPlayerView.topAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: videoPlayerView.bottomAnchor)
        ]

        // 공통 오토레이아웃 (컨트롤/시커/버튼)
        NSLayoutConstraint.activate([
            controlsOverlayView.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            controlsOverlayView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            controlsOverlayView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            controlsOverlayView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),

            playbackControlsStack.centerXAnchor.constraint(equalTo: controlsOverlayView.centerXAnchor),
            playbackControlsStack.centerYAnchor.constraint(equalTo: controlsOverlayView.centerYAnchor),

            seekerStack.leadingAnchor.constraint(equalTo: controlsOverlayView.leadingAnchor, constant: 16),
            seekerStack.trailingAnchor.constraint(equalTo: controlsOverlayView.trailingAnchor, constant: -16),
            seekerStack.bottomAnchor.constraint(equalTo: controlsOverlayView.bottomAnchor, constant: -16),

            fullscreenButton.bottomAnchor.constraint(equalTo: seekerStack.topAnchor, constant: -5),
            fullscreenButton.trailingAnchor.constraint(equalTo: controlsOverlayView.trailingAnchor, constant: -16),

            dismissButton.topAnchor.constraint(equalTo: controlsOverlayView.topAnchor, constant: 16),
            dismissButton.leadingAnchor.constraint(equalTo: controlsOverlayView.leadingAnchor, constant: 16)
        ])

        // 버튼 고정 크기 설정
        playPauseButton.widthAnchor.constraint(equalToConstant: 54).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
        backwardButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        backwardButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        forwardButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        forwardButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        fullscreenButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        fullscreenButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 20).isActive = true

        updateConstraintsForOrientation()
    }

    // MARK: - 레이아웃 변경

    /// 가로/세로 모드에 따라 제약조건 전환
    func updateConstraintsForOrientation() {
        let isLandscape = UIDevice.current.orientation.isLandscape
        if isFullscreenMode || isLandscape {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
            collectionView.isHidden = true
        } else {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            collectionView.isHidden = false
        }
    }

    // MARK: - UI 생성 유틸

    /// SF Symbol을 사용한 플레이어 버튼 생성
    /// - Parameters:
    ///   - systemName: 아이콘 이름
    ///   - useSmallConfig: 작은 버튼 여부
    /// - Returns: UIButton 인스턴스
    func createButton(systemName: String, useSmallConfig: Bool = false) -> UIButton {
        let config = useSmallConfig ? smallSymbolConfig : symbolConfig
        let button = UIButton(type: .system)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = (useSmallConfig ? 44 : 54) / 2
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }

    /// 재생/일시정지 버튼 이미지 상태 변경
    /// - Parameter isPlaying: 재생 중 여부
    func setPlayPauseImage(isPlaying: Bool) {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        let img = UIImage(systemName: imageName, withConfiguration: symbolConfig)
        playPauseButton.setImage(img, for: .normal)
        playPauseButton.configuration = .plain()
        playPauseButton.configuration?.imagePadding = isPlaying ? 8 : 0
    }

    /// 시간 라벨 생성 (monospaced font)
    /// - Parameter text: 초기 문자열
    /// - Returns: UILabel 인스턴스
    func createTimeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// 버튼 터치 다운 애니메이션
    /// - Parameters:
    ///   - button: 대상 버튼
    ///   - completion: 애니메이션 완료 시 실행할 클로저
    func animateButtonTap(_ button: UIButton, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                button.transform = .identity
            }, completion: { _ in
                completion()
            })
        }
    }
}

extension UIImage {
    /// 원형 이미지 생성
    static func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        let rect = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }
}
