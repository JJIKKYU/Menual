//
//  ProfileRestoreViewController.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import RxSwift
import UIKit
import DesignSystem

public protocol ProfileRestorePresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
    
    func restoreDiary(url: URL)
}

final class ProfileRestoreViewController: UIViewController, ProfileRestoreViewControllable {

    weak var listener: ProfileRestorePresentableListener?
    private let disposeBag = DisposeBag()

    lazy var naviView = MenualNaviView(type: .restore)
    lazy var tempBoxButton = BoxButton(frame: .zero, btnStatus: .active, btnSize: .large)
    
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

        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        setViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
}

// MARK: - ProfileRestorePresentable
extension ProfileRestoreViewController: ProfileRestorePresentable {
    func exitWithAnimation() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Darwin.exit(0)
        }
    }
}

// MARK: - UI
extension ProfileRestoreViewController {
    func setViews() {
        naviView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        }

        tempBoxButton.do {
            $0.title = "메뉴얼 가져오기"
            $0.addTarget(self, action: #selector(pressedRestoreBtn), for: .touchUpInside)
        }

        self.view.addSubview(naviView)
        self.view.addSubview(tempBoxButton)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        tempBoxButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(100)
            make.height.equalTo(56)
        }
    }
    
    func needAuthorization() {
        show(size: .large,
             buttonType: .oneBtn,
             titleText: "알림 설정을 켜주세요",
             subTitleText: "메뉴얼 복원이 완료되면 알림으로 알려드려요",
             confirmButtonText: MenualString.reminder_alert_confirm_reminder
        )
    }
}

// MARK: - IBAction
extension ProfileRestoreViewController {
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
    
    @objc
    func pressedRestoreBtn() {
        // 권한 물어보기
        let userNotiCenter = UNUserNotificationCenter.current()
        let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        userNotiCenter.requestAuthorization(options: notiAuthOptions) { (success, error) in
            if let error = error {
                print(#function, error)
                print("Reminder :: 권한 요청? error! = \(error)")
                // self.delegate?.isNeedReminderAuthorization()
                self.needAuthorization()
            }
            
            if success == true {
                print("Reminder :: 권한 요청? success! = \(success)")
                
                DispatchQueue.main.async {
                    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.zip])
                    documentPicker.delegate = self
                    // documentPicker.directoryURL = .homeDirectory
                    self.present(documentPicker, animated: true, completion: nil)
                }

            } else {
                DispatchQueue.main.async {
                    self.needAuthorization()
                }
            }
        }

    }
}

// MARK: - UIDocumentPickerViewControllerDelegate
extension ProfileRestoreViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("ProfileRestore :: cancelled!")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("ProfileRestore :: picker!")
        guard let fileURL = urls.first else { return }
        
        print("ProfileRestore :: url = \(fileURL)")
        listener?.restoreDiary(url: fileURL)
    }
}

// MARK: - DialogDelegate
extension ProfileRestoreViewController: DialogDelegate {
    func action(titleText: String) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func exit(titleText: String) {
        
    }
}
