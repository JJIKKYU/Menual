//
//  AppRootViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import DesignSystem
import MenualUtil
import RIBs
import SnapKit
import Then
import UIKit

protocol AppRootPresentableListener: AnyObject {}

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

        configureUI()
        setViews()
    }
}

// MARK: -

extension AppRootViewController {
    private func configureUI() {}

    private func setViews() {}
}

// MARK: - RootViewControllable

extension AppRootViewController {
    func setViewController(_ viewController: ViewControllable) {
        present(viewController.uiviewController, animated: false)
    }
}
