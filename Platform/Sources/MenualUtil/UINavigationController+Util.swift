//
//  UINavigationController+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/11/27.
//

import Foundation
import UIKit

extension UINavigationController {
    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)

        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }

    func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)

        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}

// MARK: - BackSwipeGesture FullWidth
public class NavigationController: UINavigationController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        // setupFullWidthBackGesture()
        print("Navi :: viewDidLoad!")
    }
    
    public var isDisabledFullWidthBackGesture: Bool = false
    public lazy var fullWidthBackGestureRecognizer = UIPanGestureRecognizer()

    private func setupFullWidthBackGesture() {
        // The trick here is to wire up our full-width `fullWidthBackGestureRecognizer` to execute the same handler as
        // the system `interactivePopGestureRecognizer`. That's done by assigning the same "targets" (effectively
        // object and selector) of the system one to our gesture recognizer.
        guard
            let interactivePopGestureRecognizer = interactivePopGestureRecognizer,
            let targets = interactivePopGestureRecognizer.value(forKey: "targets")
        else {
            return
        }

        fullWidthBackGestureRecognizer.setValue(targets, forKey: "targets")
        fullWidthBackGestureRecognizer.delegate = self
        view.addGestureRecognizer(fullWidthBackGestureRecognizer)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        view.addGestureRecognizer(swipeLeft)
    }
}

extension NavigationController: UIGestureRecognizerDelegate {
    // 한 손가락 스와이프 제스쳐를 행했을 때 실행할 액션 메서드
        @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
            // 만일 제스쳐가 있다면
            print("Navi :: gesture! = \(gesture)")
            if let swipeGesture = gesture as? UISwipeGestureRecognizer{
                print("Navi :: \(swipeGesture.direction)")
            }
            
        }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // return false
        // if let viewController = presentedViewController

//        if let imageDetailVC = topViewController as? DiaryDetailImageViewController {
//            print("Navi :: ImageDetailVC = \(imageDetailVC)")
//            return false
//        }
        
        if let navigationController = presentingViewController as? UINavigationController {
            print("Navi :: presentingViewController = \(navigationController.classForCoder),,,, \(navigationController.viewControllers[safe: 0]), \(navigationController.viewControllers[safe: 1])")
        }
        
        print("Navi :: \(isDisabledFullWidthBackGesture), gesture = \(gestureRecognizer)")
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            print("Navi :: Pangesture = \(gesture.velocity(in: view))")
            let velocity = gesture.velocity(in: view).x
            if velocity < 100.0 { return false }
        }

//         if isDisabledFullWidthBackGesture { return false }
        let isSystemSwipeToBackEnabled = interactivePopGestureRecognizer?.isEnabled == true
        let isThereStackedViewControllers = viewControllers.count > 1
        return isSystemSwipeToBackEnabled && isThereStackedViewControllers
    }
}
