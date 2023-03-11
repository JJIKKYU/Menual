//
//  ProfileRestoreConfirmViewController.swift
//  Menual
//
//  Created by 정진균 on 2023/02/26.
//

import RIBs
import RxSwift
import UIKit
import DesignSystem
import MenualUtil
import RxRelay

public protocol ProfileRestoreConfirmPresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
    func pressedRestoreBtn()
    var fileName: String? { get }
    var fileCreatedAt: String? { get }
    var menualRestoreProgressRelay: BehaviorRelay<CGFloat> { get }
    func restoreSuccess()
}

final class ProfileRestoreConfirmViewController: UIViewController, ProfileRestoreConfirmViewControllable {

    weak var listener: ProfileRestoreConfirmPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel.text = MenualString.restore_title
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
    }
    lazy var bottomBoxButton = BoxButton(frame: .zero, btnStatus: .active, btnSize: .large)
    private let fileConfirmTitleLabel = UILabel(frame: .zero)
    private let currentBackupStatusView = CurrentBackupStatusView(type: .restore)
    private let progressView = MenualProgressView(frame: .zero)
    private let disposeBag = DisposeBag()
    
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
        bind()
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
        self.view.addSubview(fileConfirmTitleLabel)
        self.view.addSubview(currentBackupStatusView)
        self.view.addSubview(bottomBoxButton)
        self.view.addSubview(progressView)
        
        self.view.bringSubviewToFront(naviView)
        
        fileConfirmTitleLabel.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = MenualString.restore_title_last_confirm
            $0.font = UIFont.AppTitle(.title_3)
            $0.textColor = Colors.grey.g100
        }
        
        bottomBoxButton.do {
            $0.title = MenualString.profile_button_restore
            $0.addTarget(self, action: #selector(pressedRestoreBtn), for: .touchUpInside)
        }
        
        progressView.do {
            $0.isHidden = true
        }
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        bottomBoxButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(34)
            make.height.equalTo(56)
        }
        
        fileConfirmTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(naviView.snp.bottom).offset(24)
        }
        
        currentBackupStatusView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(fileConfirmTitleLabel.snp.bottom).offset(24)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.leading.width.bottom.equalToSuperview()
        }
    }
    
    func bind() {
        listener?.menualRestoreProgressRelay
            .subscribe(onNext: { [weak self] progress in
                guard let self = self else { return }
                
                if progress >= 0 && progress < 1.0 {
                    self.progressView.isHidden = false
                    self.progressView.progressValue = CGFloat(progress)
                } else if progress >= 1.0 {
                    self.progressView.progressValue = CGFloat(progress)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.progressView.isHidden = true
                        self.showCompletePopup()
                    }
                    
                } else {
                    self.progressView.isHidden = true
                }
                
                print("ProfileRestoreConfirm :: progress! = \(progress)")
            })
            .disposed(by: disposeBag)
    }
    
    /// 가져오기가 완료될 경우 팝업으로 안내
    func showCompletePopup() {
        showDialog(
            dialogScreen: .profileRestore(.success),
            size: .small,
            buttonType: .oneBtn,
            titleText: MenualString.restore_alert_success,
            confirmButtonText: MenualString.writing_alert_confirm
        )
    }
}

// MARK: -
extension ProfileRestoreConfirmViewController: ProfileRestoreConfirmPresentable {
    func notVaildZipFile() {
        showDialog(
            dialogScreen: .profileRestore(.notValidZipFile),
            size: .medium,
            buttonType: .oneBtn,
            titleText: MenualString.restore_alert_title_not_menual,
            subTitleText: MenualString.restore_alert_desc_not_menual,
            confirmButtonText: MenualString.writing_alert_confirm
        )
    }
    
    func loadErrorZipFile() {
        showDialog(
            dialogScreen: .profileRestore(.errorZipFile),
            size: .large,
            buttonType: .oneBtn,
            titleText: MenualString.restore_alert_title_error,
            subTitleText: MenualString.restore_alert_desc_error,
            confirmButtonText: MenualString.writing_alert_confirm
        )
    }
    
    func fileNameAndDateSetUI() {
        currentBackupStatusView.fileName = listener?.fileName
        currentBackupStatusView.fileCreatedAt = listener?.fileCreatedAt
    }
}

// MARK: - Dialog Delegate
extension ProfileRestoreConfirmViewController: DialogDelegate {
    func action(dialogScreen: DesignSystem.DialogScreen) {
        if case .profileRestore(let profileRestoreDialog) = dialogScreen {
            switch profileRestoreDialog {
            case .success:
                listener?.restoreSuccess()
            case .errorZipFile:
                pressedBackBtn()
            case .notValidZipFile:
                pressedBackBtn()
            }
       }
    }
    
    func exit(dialogScreen: DesignSystem.DialogScreen) {
        pressedBackBtn()
    }
}


// MARK: - IBAction
extension ProfileRestoreConfirmViewController {
    @objc
    func pressedRestoreBtn() {
        listener?.pressedRestoreBtn()
    }
    
    @objc
    func pressedBackBtn() {
        print("ProfileHomeVC :: pressedBackBtn!")
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}
