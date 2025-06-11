//
//  PlayerViewController+Gestures.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//

import UIKit

/// PlayerViewController의 제스처 관련 확장
extension PlayerViewController: UIGestureRecognizerDelegate {

    /// 플레이어 오버레이 뷰에 필요한 제스처를 모두 추가
    func setupGestures() {
        // 단일 탭: 컨트롤 토글
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(toggleControlsVisibility))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(singleTap)

        // 더블 탭: 구간 점프(왼쪽: -10초, 오른쪽: +10초)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(doubleTap)

        // 단일 탭은 더블 탭 실패 시에만 인식
        singleTap.require(toFail: doubleTap)

        // 스와이프 업/다운: 전체화면 전환
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToFullscreen))
        swipeUp.direction = .up
        controlsOverlayView.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToFullscreen))
        swipeDown.direction = .down
        controlsOverlayView.addGestureRecognizer(swipeDown)
    }

    /// 더블 탭 제스처 처리: 화면 좌/우 위치에 따라 -10초/10초 점프
    /// - Parameter recognizer: UITapGestureRecognizer 인스턴스
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: controlsOverlayView)
        let midX = controlsOverlayView.bounds.midX

        if location.x < midX {
            seek(by: -10)
        } else {
            seek(by: 10)
        }
    }

    /// 스와이프 업/다운 제스처 처리: 전체화면 전환 또는 복귀
    /// - Parameter gesture: UISwipeGestureRecognizer 인스턴스
    @objc func handleSwipeToFullscreen(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .up, !UIDevice.current.orientation.isLandscape {
            setOrientation(to: .landscapeRight)
        } else if gesture.direction == .down, UIDevice.current.orientation.isLandscape {
            setOrientation(to: .portrait)
        }
    }

    /// 기기 방향을 강제로 변경
    /// - Parameter orientation: 설정할 UIInterfaceOrientation 값
    func setOrientation(to orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    /// UIControl 뷰에 제스처가 적용되지 않도록 필터링
    /// - Parameters:
    ///   - gestureRecognizer: 제스처 인식기
    ///   - touch: 터치 정보
    /// - Returns: 제스처 적용 가능 여부
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl {
            return false
        }
        return true
    }
}
