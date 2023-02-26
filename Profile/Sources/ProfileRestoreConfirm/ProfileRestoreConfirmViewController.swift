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

public protocol ProfileRestoreConfirmPresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
    func pressedRestoreBtn()
    var fileName: String? { get }
    var fileCreatedAt: String? { get }
}

final class ProfileRestoreConfirmViewController: UIViewController, ProfileRestoreConfirmViewControllable {

    weak var listener: ProfileRestoreConfirmPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel.text = "메뉴얼 가져오기"
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
    }
    lazy var bottomBoxButton = BoxButton(frame: .zero, btnStatus: .active, btnSize: .large)
    private let fileConfirmTitleLabel = UILabel(frame: .zero)
    private let currentBackupStatusView = CurrentBackupStatusView(type: .restore)
    
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
        self.view.addSubview(fileConfirmTitleLabel)
        self.view.addSubview(currentBackupStatusView)
        self.view.addSubview(bottomBoxButton)
        
        self.view.bringSubviewToFront(naviView)
        
        fileConfirmTitleLabel.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "파일이 맞는지 확인해주세요."
            $0.font = UIFont.AppTitle(.title_3)
            $0.textColor = Colors.grey.g100
        }
        
        bottomBoxButton.do {
            $0.title = "메뉴얼 가져오기"
            $0.addTarget(self, action: #selector(pressedRestoreBtn), for: .touchUpInside)
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
    }
}

// MARK: -
extension ProfileRestoreConfirmViewController: ProfileRestoreConfirmPresentable {
    func notVaildZipFile() {
        show(size: .medium,
             buttonType: .oneBtn,
             titleText: "메뉴얼 백업 파일이 아니에요",
             subTitleText: "파일을 제대로 선택했는지 확인해주세요.",
             confirmButtonText: "확인"
        )
    }
    
    func loadErrorZipFile() {
        show(size: .large,
             buttonType: .oneBtn,
             titleText: "메뉴얼을 가져올 수 없어요",
             subTitleText:
             """
             메뉴얼을 가져오는 중 오류가 발생했어요.
             잠시 후 다시 시도해주세요.
             """,
             confirmButtonText: "확인"
        )
    }
    
    func fileNameAndDateSetUI() {
        currentBackupStatusView.fileName = listener?.fileName
        currentBackupStatusView.fileCreatedAt = listener?.fileCreatedAt
    }
}

// MARK: - Dialog Delegate
extension ProfileRestoreConfirmViewController: DialogDelegate {
    func action(titleText: String) {
        pressedBackBtn()
    }
    
    func exit(titleText: String) {
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
