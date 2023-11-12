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
    private let progressView: MenualProgressView = .init(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background

        configureUI()
        setViews()
    }
}

// MARK: -

extension AppRootViewController {
    private func configureUI() {
        progressView.do {
            $0.isHidden = false
        }
    }

    private func setViews() {
        view.addSubview(progressView)

        progressView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - RootViewControllable

extension AppRootViewController {
    func setViewController(_ viewController: ViewControllable) {
        present(viewController.uiviewController, animated: false)
    }
}
