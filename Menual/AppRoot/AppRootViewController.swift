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
    
    private let splashView = UIView().then {
        $0.isUserInteractionEnabled = false
        $0.backgroundColor = Colors.background
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splashView.do {
            print("")
            let menualImageView = UIImageView(image: Asset.splashMenual.image)
            $0.addSubview(menualImageView)
            menualImageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview().inset(30)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(130)
            }
        }

        self.view.addSubview(splashView)
        splashView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        view.backgroundColor = Colors.background
    }
}

// MARK: - RootViewControllable
extension AppRootViewController {
    /*
  func present(_ viewController: ViewControllable, animated: Bool) {
    present(viewController.uiviewController, animated: animated)
  }
     */

    
    func setViewController(_ viewController: ViewControllable) {
        present(viewController.uiviewController, animated: false)
    }
}

