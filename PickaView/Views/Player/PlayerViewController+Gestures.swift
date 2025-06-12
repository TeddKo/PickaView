////
////  PlayerViewController+Gestures.swift
////  PickaView
////
////  Created by junil on 6/11/25.
////
//
//import UIKit
//
///// PlayerViewController의 제스처 관련 확장
//extension PlayerViewController: UIGestureRecognizerDelegate {
//
//    /// 플레이어 오버레이 뷰에 필요한 제스처를 모두 추가
//    func setupGestures() {
//        // 단일/더블 탭은 항상 등록
//        let singleTap = UITapGestureRecognizer(target: self, action: #selector(toggleControlsVisibility))
//        singleTap.numberOfTapsRequired = 1
//        singleTap.delegate = self
//        controlsOverlayView.addGestureRecognizer(singleTap)
//
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
//        doubleTap.numberOfTapsRequired = 2
//        doubleTap.delegate = self
//        controlsOverlayView.addGestureRecognizer(doubleTap)
//
//        singleTap.require(toFail: doubleTap)
//
//        // **스와이프 업: 기본 모드에서만**
//        if !isFullscreenMode {
//            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToFullscreen))
//            swipeUp.direction = .up
//            controlsOverlayView.addGestureRecognizer(swipeUp)
//        }
//
//        // **스와이프 다운: 전체화면에서만**
//        if isFullscreenMode {
//            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToFullscreen))
//            swipeDown.direction = .down
//            controlsOverlayView.addGestureRecognizer(swipeDown)
//        }
//    }
//
//    /// 더블 탭 제스처 처리: 화면 좌/우 위치에 따라 -10초/10초 점프
//    /// - Parameter recognizer: UITapGestureRecognizer 인스턴스
//    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
//        let location = recognizer.location(in: controlsOverlayView)
//        let midX = controlsOverlayView.bounds.midX
//
//        if location.x < midX {
//            seek(by: -10)
//        } else {
//            seek(by: 10)
//        }
//    }
//
//    /// 스와이프 업/다운 제스처 처리: 전체화면 전환 또는 복귀
//    /// - Parameter gesture: UISwipeGestureRecognizer 인스턴스
//    @objc func handleSwipeToFullscreen(_ gesture: UISwipeGestureRecognizer) {
//        if #available(iOS 16, *) {
//            print("#### if")
//            DispatchQueue.main.async {
//                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//                self.setNeedsUpdateOfSupportedInterfaceOrientations()
//                self.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
//                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape)) { error in
//                    print(error)
//                    print(windowScene?.effectiveGeometry ?? "")
//                }
//            }
//
//        } else {
//            print("#### else")
//            //               appDelegate.myOrientation = .landscape
//            //               UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
//            //               UIView.setAnimationsEnabled(true)
//        }
//    }
//
//    /// 기기 방향을 강제로 변경
//    /// - Parameter orientation: 설정할 UIInterfaceOrientation 값
//    func setOrientation(to orientation: UIInterfaceOrientation) {
//        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
//        UIViewController.attemptRotationToDeviceOrientation()
//    }
//
//    /// UIControl 뷰에 제스처가 적용되지 않도록 필터링
//    /// - Parameters:
//    ///   - gestureRecognizer: 제스처 인식기
//    ///   - touch: 터치 정보
//    /// - Returns: 제스처 적용 가능 여부ㄹ
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        if touch.view is UIControl {
//            return false
//        }
//        return true
//    }
//}

import UIKit

extension PlayerViewController: UIGestureRecognizerDelegate {

    func setupGestures() {
        controlsOverlayView.gestureRecognizers?.forEach { controlsOverlayView.removeGestureRecognizer($0) }

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(toggleControlsVisibility))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(singleTap)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        controlsOverlayView.addGestureRecognizer(doubleTap)
        singleTap.require(toFail: doubleTap)

        if !isFullscreenMode {
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToFullscreen))
            swipeUp.direction = .up
            controlsOverlayView.addGestureRecognizer(swipeUp)
        }
    }

    @objc func toggleControlsVisibility() {
        areControlsVisible.toggle()
        let alpha: CGFloat = areControlsVisible ? 1.0 : 0.0

        UIView.animate(withDuration: 0.3) {
            self.playbackControlsStack.alpha = alpha
            self.seekerStack.alpha = alpha
        }

        if areControlsVisible && isPlaying {
            scheduleControlsHide()
        } else {
            cancelControlsHide()
        }
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

    @objc func handleSwipeToFullscreen(_ gesture: UISwipeGestureRecognizer) {
        guard !isFullscreenMode else { return }
        let isPortrait: Bool
        if let orientation = view.window?.windowScene?.interfaceOrientation {
            isPortrait = orientation.isPortrait
        } else {
            isPortrait = UIDevice.current.orientation.isPortrait
        }
        guard isPortrait else { return }
        presentFullscreen()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}
