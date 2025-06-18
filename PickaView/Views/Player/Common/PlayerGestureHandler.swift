//
//  PlayerGestureHandler.swift
//  PickaView
//
//  Created by 장지현 on 6/17/25.
//

import UIKit
import AVKit

protocol PlayerGestureDelegate: AnyObject {
    func didToggleControls()
    func didSeek(by seconds: Double)
    func didStartFastForward()
    func didStopFastForward()
    func requestEnterFullscreen()
    func requestDismissToHome()
}

final class PlayerGestureHandler: NSObject, UIGestureRecognizerDelegate {

    weak var controlsOverlayView: UIView?
    weak var videoContainerView: UIView?
    weak var delegate: PlayerGestureDelegate?
    
    /// 플레이어 오버레이 뷰에 필요한 모든 제스처를 등록합니다.
    /// - 단일 탭: 컨트롤 토글
    /// - 더블 탭: 10초 앞으로/뒤로 시킹
    /// - (세로) 위로 스와이프: 전체화면 진입
    func attachGestures() {
        guard let controlsOverlayView else { return }
        
        // 기존 제스처 모두 제거
        controlsOverlayView.gestureRecognizers?.forEach {
            controlsOverlayView.removeGestureRecognizer($0)
        }

        // 단일 탭: 컨트롤 show/hide
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(singleTap)

        // 더블 탭: 10초 skip (좌/우)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)

        // 길게 누르면 2배속
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.delegate = self
        controlsOverlayView.addGestureRecognizer(longPress)
        
        // 위로 스와이프 → 전체화면
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
        swipeUp.direction = .up
        controlsOverlayView.addGestureRecognizer(swipeUp)
        
        // 아래로 스와이프 → 홈으로 이동
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        controlsOverlayView.addGestureRecognizer(swipeDown)
    }

    // MARK: - 제스처 핸들러
    
    @objc private func handleSingleTap() {
        delegate?.didToggleControls()
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: controlsOverlayView)
        guard let bounds = videoContainerView?.bounds else { return }
        let isLeft = location.x < bounds.midX
        delegate?.didSeek(by: isLeft ? -10 : 10)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            delegate?.didStartFastForward()
        case .ended, .cancelled:
            delegate?.didStopFastForward()
        default:
            break
        }
    }

    @objc private func handleSwipeUp() {
        delegate?.requestEnterFullscreen()
    }

    @objc private func handleSwipeDown() {
        delegate?.requestDismissToHome()
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}
