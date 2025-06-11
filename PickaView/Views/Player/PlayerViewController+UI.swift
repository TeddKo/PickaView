//
//  PlayerViewController+UI.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//

import UIKit

extension PlayerViewController {

    // 버튼 아이콘 config(한 번만 정의, 전역 변수처럼 씀)
    var symbolConfig: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 36, weight: .regular, scale: .large)
    }

    // 작은 크기(forward/backward)
    var smallSymbolConfig: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: 26, weight: .regular, scale: .medium)
    }

    // MARK: - UI Setup
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

    func setPlayPauseImage(isPlaying: Bool) {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        // 이미지를 config와 함께 만듭니다.
        let img = UIImage(systemName: imageName, withConfiguration: symbolConfig)
        playPauseButton.setImage(img, for: .normal)

        // pause일 때만 인셋을 음수로 조금 줘서 크기를 맞춤 (필요시 숫자 조정)
        if isPlaying {
            playPauseButton.imageEdgeInsets = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
        } else {
            playPauseButton.imageEdgeInsets = .zero
        }
    }

    func createTimeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

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
