//
//  PlayerViewController+Gestures.swift
//  PickaView
//
//  Created by junil on 6/10/25.
//

import UIKit

extension PlayerViewController: UIViewControllerTransitioningDelegate {

    /// 비디오 플레이어 오버레이에 싱글/더블 탭 제스처를 설정
    ///
    /// - Note: 싱글 탭은 컨트롤(재생바 등) 표시 토글, 더블 탭은 앞/뒤 15초 이동을 담당
    func setupGestures() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(toggleControlsVisibility))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(singleTap)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(doubleTap)

        // 더블탭 인식 시 싱글탭이 호출되지 않도록 설정
        singleTap.require(toFail: doubleTap)
    }

    @objc func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.videoContainerView.addGestureRecognizer(panGesture)
    }

    /// 더블 탭 위치에 따라 앞/뒤 15초 이동 기능을 수행
    ///
    /// - Parameter recognizer: 더블 탭 제스처 리코그나이저
    ///
    /// - Note: 좌측 더블탭은 -15초, 우측은 +15초로 이동
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: controlsOverlayView)
        let midX = controlsOverlayView.bounds.midX

        if location.x < midX {
            seek(by: -15)
        } else {
            seek(by: 15)
        }
    }

    /// 팬 제스처를 처리하여 전체화면으로 전환하거나 원래대로 복귀
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let progress = -translation.y / (view.bounds.height / 2) // 위로 스와이프 시 progress 증가

        switch recognizer.state {
        case .began:
            // 위로 스와이프할 때만 전체화면 전환 시작
            if translation.y < 0 {
                interactiveAnimator = UIPercentDrivenInteractiveTransition()

                // 👇 여기서 player와 playerLayer를 전달해줌
                let fullscreenVC = FullscreenPlayerViewController()
                fullscreenVC.player = self.player
                fullscreenVC.playerLayer = self.playerLayer

                fullscreenVC.modalPresentationStyle = .custom
                fullscreenVC.transitioningDelegate = self
                present(fullscreenVC, animated: true)
            }

        case .changed:
            interactiveAnimator?.update(progress)

        case .ended:
            if progress > 0.3 {
                interactiveAnimator?.finish()
            } else {
                interactiveAnimator?.cancel()
            }
            interactiveAnimator = nil

        default:
            break
        }
    }

    /// 제스처 인식이 UIControl(버튼 등)에서는 동작하지 않도록 필터링
    ///
    /// - Parameters:
    ///   - gestureRecognizer: 현재 인식 중인 제스처 리코그나이저
    ///   - touch: 터치 이벤트 정보
    /// - Returns: 해당 터치가 UIControl이 아니면 true(제스처 인식), UIControl이면 false(무시)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl {
            return false
        }
        return true
    }

    /// Present 시 사용할 커스텀 애니메이터를 반환
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // transitioningView: 애니메이션의 시작/끝점 역할을 할 뷰
        return FullscreenTransitionAnimator(presenting: true, transitioningView: videoContainerView)
    }

    /// Dismiss 시 사용할 커스텀 애니메이터를 반환
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 전체화면 뷰 컨트롤러에서 원래 뷰로 돌아올 때도 videoContainerView를 기준으로 애니메이션
        guard let fullscreenVC = dismissed as? FullscreenPlayerViewController else { return nil }
        return FullscreenTransitionAnimator(presenting: false, transitioningView: fullscreenVC.view)
    }

    /// 인터랙티브 Present를 위한 인터랙션 컨트롤러를 반환
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveAnimator
    }

    /// 인터랙티브 Dismiss를 위한 인터랙션 컨트롤러를 반환
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // 전체화면에서 아래로 스와이프하여 되돌아오는 기능 구현 시 필요
        // 지금 예제에서는 FullscreenPlayerViewController에서 이 부분을 처리
        return interactiveAnimator
    }
}
