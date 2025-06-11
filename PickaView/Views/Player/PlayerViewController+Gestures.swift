//
//  PlayerViewController+Gestures.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//

import UIKit

extension PlayerViewController: UIGestureRecognizerDelegate {

    // MARK: - Gestures
    func setupGestures() {
        // 단일 탭 제스처
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(toggleControlsVisibility))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(singleTap)

        // 더블 탭 제스처
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(doubleTap)

        // 단일 탭은 더블 탭이 실패했을 때만 인식되도록 설정
        singleTap.require(toFail: doubleTap)

        // ✅ 스와이프 제스처 추가
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToFullscreen))
        swipeUp.direction = .up
        controlsOverlayView.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToFullscreen))
        swipeDown.direction = .down
        controlsOverlayView.addGestureRecognizer(swipeDown)
    }

    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: controlsOverlayView)
        let midX = controlsOverlayView.bounds.midX

        if location.x < midX {
            seek(by: -10)
        } else {
            seek(by: 10)
        }
    }

    // ✅ 스와이프 제스처 핸들러 추가
    @objc func handleSwipeToFullscreen(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .up, !UIDevice.current.orientation.isLandscape {
            setOrientation(to: .landscapeRight)
        } else if gesture.direction == .down, UIDevice.current.orientation.isLandscape {
            setOrientation(to: .portrait)
        }
    }

    // ✅ 화면 방향 전환을 위한 메서드 추가
    func setOrientation(to orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 터치된 뷰가 UIControl(버튼, 슬라이더 등)의 하위 뷰인 경우 제스처를 인식하지 않습니다.
        if touch.view is UIControl {
            return false
        }
        return true
    }
}
