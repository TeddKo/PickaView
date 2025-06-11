//
//  PlayerControlsView.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//


import UIKit

final class PlayerControlsView: UIView {
    let playPauseButton = UIButton()
    let backwardButton = UIButton()
    let forwardButton = UIButton()
    let currentTimeLabel = UILabel()
    let totalDurationLabel = UILabel()
    let progressSlider = UISlider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .clear
        
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.tintColor = .white
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false

        backwardButton.setImage(UIImage(systemName: "10.arrow.trianglehead.counterclockwise"), for: .normal)
        backwardButton.tintColor = .white
        backwardButton.translatesAutoresizingMaskIntoConstraints = false

        forwardButton.setImage(UIImage(systemName: "10.arrow.trianglehead.clockwise"), for: .normal)
        forwardButton.tintColor = .white
        forwardButton.translatesAutoresizingMaskIntoConstraints = false

        currentTimeLabel.text = "00:00"
        currentTimeLabel.textColor = .white
        currentTimeLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        totalDurationLabel.text = "00:00"
        totalDurationLabel.textColor = .white
        totalDurationLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        totalDurationLabel.translatesAutoresizingMaskIntoConstraints = false

        progressSlider.minimumValue = 0
        progressSlider.value = 0
        progressSlider.tintColor = .magenta
        progressSlider.thumbTintColor = .magenta
        progressSlider.translatesAutoresizingMaskIntoConstraints = false

        let playStack = UIStackView(arrangedSubviews: [backwardButton, playPauseButton, forwardButton])
        playStack.axis = .horizontal
        playStack.alignment = .center
        playStack.distribution = .equalSpacing
        playStack.spacing = 40
        playStack.translatesAutoresizingMaskIntoConstraints = false

        let seekerStack = UIStackView(arrangedSubviews: [currentTimeLabel, progressSlider, totalDurationLabel])
        seekerStack.axis = .horizontal
        seekerStack.spacing = 8
        seekerStack.alignment = .center
        seekerStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(playStack)
        addSubview(seekerStack)

        NSLayoutConstraint.activate([
            playStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            playStack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),

            seekerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            seekerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            seekerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
}
