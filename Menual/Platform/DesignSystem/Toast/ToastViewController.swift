//
//  ToastViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/11/10.
//

import UIKit
import Then
import SnapKit

class ToastView: UIView {
    
    public var titleText: String = "Toast 타이틀입니다." {
        didSet { setText() }
    }
    
    private let toastView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.tint.main.v800
    }
    
    private let toastTitleLabel = UILabel().then {
        $0.text = "Toast 타이틀입니다."
        $0.font = UIFont.AppTitle(.title_1)
        $0.textColor = Colors.tint.main.v100
        $0.textAlignment = .center
    }
    
    init() {
        super.init(frame: CGRect.zero)
        categoryName = "toast"
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = Colors.tint.main.v800
        addSubview(toastTitleLabel)
        
//        toastView.snp.makeConstraints { make in
//            make.leading.equalToSuperview()
//            make.width.equalToSuperview()
//            make.top.equalToSuperview()
//            make.height.equalTo(UIApplication.topSafeAreaHeight + 36)
//        }
        
        toastTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(18)
        }
    }

    func setText() {
        self.toastTitleLabel.text = titleText
    }
}

extension UIViewController {

func showToast(message : String) -> ToastView {
    let toastView = ToastView()

    toastView.titleText = message
    
    view.addSubview(toastView)
    toastView.snp.makeConstraints { make in
        make.leading.equalToSuperview()
        make.width.equalToSuperview()
        make.top.equalToSuperview().inset(-UIApplication.topSafeAreaHeight - 36)
        make.height.equalTo(UIApplication.topSafeAreaHeight + 36)
    }
    toastView.alpha = 1.0

    view.layoutIfNeeded()
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
        toastView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(0)
        }
        self.view.layoutIfNeeded()
    } completion: { _ in
        
    }

    UIView.animate(withDuration: 0.3, delay: 2, options: .curveEaseInOut, animations: {
        toastView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(-UIApplication.topSafeAreaHeight - 36)
        }
        self.view.layoutIfNeeded()
    }, completion: {(isCompleted) in
        toastView.removeFromSuperview()
    })
    return toastView
    }
}
