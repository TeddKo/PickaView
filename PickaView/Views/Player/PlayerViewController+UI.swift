//
//  PlayerViewController+UI.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//

import UIKit

/// PlayerViewController의 UI 관련 기능 확장
extension PlayerViewController {

    /// 큰 버튼용 SF Symbol config
    var symbolConfig: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 36, weight: .regular, scale: .large)
    }

    /// 작은 버튼용 SF Symbol config (forward/backward)
    var smallSymbolConfig: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 26, weight: .regular, scale: .medium)
    }

    // MARK: - UI Setup

    /// 전체 UI 컴포넌트와 오토레이아웃을 세팅
    func setupUI() {
        view.addSubview(videoContainerView)
        view.addSubview(contentScrollView)

        videoContainerView.addSubview(controlsOverlayView)
        controlsOverlayView.addSubview(playbackControlsStack)
        controlsOverlayView.addSubview(seekerStack)

        let safeArea = view.safeAreaLayoutGuide

        portraitConstraints = [
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            videoContainerView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9.0/16.0),

            contentScrollView.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        landscapeConstraints = [
            videoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]

        NSLayoutConstraint.activate([
            controlsOverlayView.topAnchor.constraint(equalTo: videoContainerView.topAnchor),
            controlsOverlayView.bottomAnchor.constraint(equalTo: videoContainerView.bottomAnchor),
            controlsOverlayView.leadingAnchor.constraint(equalTo: videoContainerView.leadingAnchor),
            controlsOverlayView.trailingAnchor.constraint(equalTo: videoContainerView.trailingAnchor),

            playbackControlsStack.centerXAnchor.constraint(equalTo: controlsOverlayView.centerXAnchor),
            playbackControlsStack.centerYAnchor.constraint(equalTo: controlsOverlayView.centerYAnchor),

            seekerStack.leadingAnchor.constraint(equalTo: controlsOverlayView.leadingAnchor, constant: 16),
            seekerStack.trailingAnchor.constraint(equalTo: controlsOverlayView.trailingAnchor, constant: -16),
            seekerStack.bottomAnchor.constraint(equalTo: controlsOverlayView.bottomAnchor, constant: -10)
        ])

        addDummyContentToScrollView()
        updateConstraintsForOrientation()
    }

    /// 기기 방향에 따라 오토레이아웃 제약을 적용
    func updateConstraintsForOrientation() {
        if UIDevice.current.orientation.isLandscape {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
            contentScrollView.isHidden = true
        } else {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            contentScrollView.isHidden = false
        }
    }

    /// 시스템 심볼로 UIButton을 생성
    /// - Parameters:
    ///   - systemName: SF Symbol 이름
    ///   - useSmallConfig: 작은 버튼 여부
    /// - Returns: 설정된 UIButton
    func createButton(systemName: String, useSmallConfig: Bool = false) -> UIButton {
        let config = useSmallConfig ? smallSymbolConfig : symbolConfig
        let button = UIButton(type: .system)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false

        let size: CGFloat = useSmallConfig ? 44 : 54
        button.widthAnchor.constraint(equalToConstant: size).isActive = true
        button.heightAnchor.constraint(equalToConstant: size).isActive = true
        button.layer.cornerRadius = size / 2

        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit

        return button
    }

    /// 재생/일시정지 버튼의 이미지를 현재 상태에 맞게 변경
    /// - Parameter isPlaying: true면 pause, false면 play 이미지
    func setPlayPauseImage(isPlaying: Bool) {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        let img = UIImage(systemName: imageName, withConfiguration: symbolConfig)
        playPauseButton.setImage(img, for: .normal)

        // 일시정지 아이콘만 살짝 더 크게(인셋)
        if isPlaying {
            playPauseButton.imageEdgeInsets = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
        } else {
            playPauseButton.imageEdgeInsets = .zero
        }
    }

    /// 시간 표시용 UILabel을 만듬
    /// - Parameter text: 초기 텍스트 (예: "00:00")
    /// - Returns: 설정된 UILabel
    func createTimeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// 버튼 터치 애니메이션을 실행
    /// - Parameters:
    ///   - button: 애니메이션할 버튼
    ///   - completion: 애니메이션 후 실행할 클로저
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

    /// 스크롤뷰에 더미 컨텐츠 뷰(예시용)를 추가
    func addDummyContentToScrollView() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for _ in 1...5 {
            let dummyView = UIView()
            dummyView.backgroundColor = .systemGray4
            dummyView.layer.cornerRadius = 15
            dummyView.heightAnchor.constraint(equalToConstant: 220).isActive = true
            stackView.addArrangedSubview(dummyView)
        }

        contentScrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentScrollView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor, constant: -15),
            stackView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, constant: -30)
        ])
    }
}
