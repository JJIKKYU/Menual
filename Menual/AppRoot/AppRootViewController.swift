//
//  AppRootViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import UIKit
import DesignSystem
import Then
import MenualUtil
import SnapKit

protocol AppRootPresentableListener: AnyObject {
}

final class AppRootViewController:
  UIViewController,
  AppRootPresentable,
  AppRootViewControllable
{

  // MARK: - RootPresentable
  
  weak var listener: AppRootPresentableListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
    }
}

// MARK: - RootViewControllable
extension AppRootViewController {
    func setViewController(_ viewController: ViewControllable) {
        present(viewController.uiviewController, animated: false)
    }
}

