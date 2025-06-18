//
//  PlayerViewController+Gestures.swift
//  PickaView
//
//  Created by junil on 6/11/25.
//

import UIKit

/// PlayerViewController의 제스처 관련 확장
extension PlayerViewController: UIGestureRecognizerDelegate {

    // MARK: - 제스처 초기화

    /// 플레이어 오버레이 뷰에 필요한 모든 제스처를 등록합니다.
    /// - 단일 탭: 컨트롤 토글
    /// - 더블 탭: 10초 앞으로/뒤로 시킹
    /// - (세로) 위로 스와이프: 전체화면 진입
    func setupGestures() {
        // 기존 제스처 모두 제거
        controlsOverlayView.gestureRecognizers?.forEach {
            controlsOverlayView.removeGestureRecognizer($0)
        }

        // 단일 탭: 컨트롤 show/hide
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(toggleControlsVisibility))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(singleTap)

        // 더블 탭: 10초 skip (좌/우)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)

        // 아래로 스와이프 → 홈으로 이동
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDownToHome))
        swipeDown.direction = .down
        controlsOverlayView.addGestureRecognizer(swipeDown)

        // (세로모드일 때만) 위로 스와이프 → 전체화면
        if !isFullscreenMode {
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToFullscreen))
            swipeUp.direction = .up
            controlsOverlayView.addGestureRecognizer(swipeUp)
        }
        
        // 길게 누르면 2배속
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.delegate = self
        controlsOverlayView.addGestureRecognizer(longPress)
    }

    // MARK: - 제스처 핸들러

    /// 단일 탭: 컨트롤(재생버튼, 시커 등) show/hide 토글
    @objc func toggleControlsVisibility() {
        areControlsVisible.toggle()
        let alpha: CGFloat = areControlsVisible ? 1.0 : 0.0

        UIView.animate(withDuration: 0.3) {
            self.playbackControlsStack.alpha = alpha
            self.seekerStack.alpha = alpha
            self.fullscreenButton.alpha = alpha
            self.exitFullscreenButton.alpha = alpha
            self.dismissButton.alpha = alpha
        }

        if areControlsVisible && isPlaying {
            scheduleControlsHide()
        } else {
            cancelControlsHide()
        }
    }

    /// 더블 탭: 왼쪽/오른쪽 10초 skip
    /// - Parameter recognizer: UITapGestureRecognizer
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
//        let container: UIView = isFullscreenMode ? view : videoContainerView
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        hideControls()
        
        let location = recognizer.location(in: controlsOverlayView)
        let midX = controlsOverlayView.bounds.midX
        
        // 아이콘 생성
        let iconName = location.x < midX ? "backward.fill" : "forward.fill"
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.alpha = 0.0
        iconView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)

        // 중앙 위치 계산 (좌/우) - videoContainerView 기준
        let containerBounds = controlsOverlayView.bounds
        let centerY = containerBounds.midY
        let centerX = location.x < midX ? containerBounds.width * 0.25 : containerBounds.width * 0.75
        iconView.center = CGPoint(x: centerX, y: centerY)

        controlsOverlayView.addSubview(iconView)
//        container.insertSubview(iconView, belowSubview: controlsOverlayView)

        // 애니메이션 처리
        UIView.animate(withDuration: 0.15, animations: {
            iconView.alpha = 1.0
            iconView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.2, options: [], animations: {
                iconView.alpha = 0.0
                iconView.transform = .identity
            }, completion: { _ in
                iconView.removeFromSuperview()
            })
        }

        if location.x < midX {
            seek(by: -10)
        } else {
            seek(by: 10)
        }
    }

    /// 길게 누르면 2배속, 떼면 1배속 (재생 중일 때만 적용)
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let player, player.rate != 0 else { return } // 재생 중일 때만 처리

        switch gesture.state {
        case .began:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
            player.rate = 2.0
            rateTwoView.isHidden = false
        case .ended, .cancelled, .failed:
            player.rate = 1.0
            rateTwoView.isHidden = true
        default:
            break
        }
    }

    @objc func handleSwipeToFullscreen(_ gesture: UISwipeGestureRecognizer) {
        presentFullscreen()
    }

    /// 아래로 스와이프 시 홈으로 복귀
    @objc func handleSwipeDownToHome(_ gesture: UISwipeGestureRecognizer) {
        if isFullscreenMode {
            // 전체화면 모드일 경우에는 FullscreenPlayerViewController에서 내려가야 하므로 무시
            return
        }

        // 내비게이션에서 푸시된 상태라면 pop, 모달이라면 dismiss
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    /// UIControl(버튼, 슬라이더 등)에는 제스처 적용 X
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}
