//
//  FullscreenTransitionAnimator.swift
//  PickaView
//
//  Created by junil on 6/10/25.
//
// FullscreenTransitionAnimator.swift

import UIKit

class FullscreenTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let presenting: Bool
    weak var transitioningView: UIView?

    init(presenting: Bool, transitioningView: UIView?) {
        self.presenting = presenting
        self.transitioningView = transitioningView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.38
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let transitioningView = self.transitioningView else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        let duration = transitionDuration(using: transitionContext)

        // [수정] SceneDelegate 참조 로직 변경
        let sceneDelegate = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })?
            .delegate as? SceneDelegate

        let initialFrame = transitioningView.convert(transitioningView.bounds, to: containerView)
        let finalFrame = transitionContext.finalFrame(for: toVC)
        let snapshot = transitioningView.snapshotView(afterScreenUpdates: false)!
        snapshot.frame = initialFrame

        if presenting {
            containerView.addSubview(toVC.view)
            containerView.addSubview(snapshot)
            toVC.view.isHidden = true
            transitioningView.isHidden = true

            // [수정] SceneDelegate 대신 AppOrientationManager의 값을 변경
            AppOrientationManager.supportedOrientations = .landscape

            // [추가] iOS 16+ 기기 방향 업데이트 요청 (이 부분은 원래 코드에 있어야 합니다)
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            } else {
                UIViewController.attemptRotationToDeviceOrientation()
            }

            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                snapshot.frame = finalFrame
            }) { _ in
                toVC.view.isHidden = false
                snapshot.removeFromSuperview()
                transitioningView.isHidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else { // Dismissing
            let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: false)!
            fromSnapshot.frame = fromVC.view.frame
            containerView.addSubview(fromSnapshot)
            fromVC.view.isHidden = true

            // [수정] SceneDelegate 대신 AppOrientationManager의 값을 변경
            AppOrientationManager.supportedOrientations = .portrait

            // [추가] iOS 16+ 기기 방향 업데이트 요청 (이 부분은 원래 코드에 있어야 합니다)
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            } else {
                UIViewController.attemptRotationToDeviceOrientation()
            }

            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                fromSnapshot.frame = initialFrame
            }) { _ in
                if !transitionContext.transitionWasCancelled {
                    transitioningView.isHidden = false
                }
                fromSnapshot.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
