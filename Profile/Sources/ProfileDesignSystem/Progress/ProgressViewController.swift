//
//  ProgressViewController.swift
//  Menual
//
//  Created by 정진균 on 2023/03/01.
//

import RIBs
import RxSwift
import UIKit
import DesignSystem

protocol ProgressPresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class ProgressViewController: UIViewController, ProgressPresentable, ProgressViewControllable {

    weak var listener: ProgressPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.titleLabel.text = "Progress"
    }
    private let progress = MenualProgressView(frame: .zero)
    private lazy var slider = UISlider(frame: .zero).then {
        $0.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        setViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
    
    func setViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.view.addSubview(naviView)
        self.view.addSubview(progress)
        self.view.addSubview(slider)
        self.view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        progress.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(naviView.snp.bottom)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        slider.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(140)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
        }
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
    
    @objc
    func sliderValueDidChange(_ sender: UISlider!) {
        progress.progressValue = CGFloat(sender.value)
    }
}
