//
//  DialogViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/10/08.
//

import UIKit
import SnapKit
import Then
import MenualUtil

public enum DialogSize {
    case small
    case medium
    case large
}

public enum DialogButtonType {
    case oneBtn
    case twoBtn
}

public enum DialogScreen {
    case diaryWriting(DiaryWritingDialog)
    case diaryDetail(DiaryDetailDialog)
    case diarySearch(DiarySearchDialog)
    case diaryBottomSheet(DiaryBottomSheetDialog)
    case profileHome(ProfileHomeDialog)
    case profileBackup(ProfileBackupDialog)
    case profileRestore(ProfileRestoreDialog)
}

public enum DiaryWritingDialog {
    case writingCancel
    case writing
    case editCancel
    case edit
    case deletePhoto
    case camera
}

public enum DiaryDetailDialog {
    case replyCancel
    case replyDelete
    case reply
    case hide
}

public enum DiarySearchDialog {
    case delete
}

public enum DiaryBottomSheetDialog {
    case hide
    case diaryDelete
    case reminderAuth
    case reminderEnable
}

public enum ProfileBackupDialog {
    case nothingBackup
}

public enum ProfileRestoreDialog {
    case success
    case errorZipFile
    case notValidZipFile
}

public enum ProfileHomeDialog {
    case notificationAuthorization
}

// Dialog의 버튼의 액션을 처리하는 Delegate입니다.
public protocol DialogDelegate: AnyObject {
    func action(dialogScreen: DialogScreen)
    func exit(dialogScreen: DialogScreen)
}


public class DialogViewController: UIViewController {
    
    public var dialogScreen: DialogScreen?
    public weak var delegate: DialogDelegate?
    
    public var titleText: String = "타이틀입니다" {
        didSet { setText() }
    }
    
    public var subTitleText: String = "서브타이틀 입니다." {
        didSet { setText() }
    }
    
    public var cancleText: String = "취소" {
        didSet { setText() }
    }
    
    public var confirmText: String = "확인" {
        didSet { setText() }
    }
    
    private let dialogView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g800
        $0.AppShadow(.shadow_6)
        $0.AppCorner(.tiny)
    }
    
    private let dialogTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = Colors.grey.g100
        $0.textAlignment = .center
        $0.text = "안녕하세요 반갑습니다."
        $0.setLineHeight(lineHeight: 1.28)
        $0.numberOfLines = 0
    }
    
    private let subDialogTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g400
        $0.textAlignment = .center
        $0.text = "안녕하세요 반갑습니다."
        $0.numberOfLines = 1
    }
    
    public var dialogButtonType: DialogButtonType = .twoBtn {
        didSet {  }
    }
    
    public var dialogSize: DialogSize = .small {
        didSet {  }
    }
    
    // buttonType이 oneButton일때만 쓰이는 버튼
    private lazy var oneButton = UIButton().then {
        $0.actionName = "confirm"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.tint.main.v300
        
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitleColor(Colors.grey.g800, for: .normal)
        $0.setTitle("텍스트", for: .normal)
        
        $0.layer.cornerRadius = 8
        $0.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner

        ]
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(pressedConfirmBtn), for: .touchUpInside)
    }
    
    // buttonType이 twoButton일때만 쓰이는 버튼
    private lazy var leftButton = UIButton().then {
        $0.actionName = "cancel"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.tint.main.v300
        
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitleColor(Colors.tint.main.v800, for: .normal)
        $0.setTitle("텍스트", for: .normal)
        
        $0.layer.cornerRadius = 8
        $0.layer.maskedCorners = [
            .layerMinXMaxYCorner
        ]
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(pressedCancelBtn), for: .touchUpInside)
    }
    
    // buttonType이 twoButton일때만 쓰이는 버튼
    private lazy var rightButton = UIButton().then {
        $0.actionName = "confirm"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.tint.main.v300
        
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitleColor(Colors.grey.g800, for: .normal)
        $0.setTitle("텍스트", for: .normal)
        
        $0.layer.cornerRadius = 8
        $0.layer.maskedCorners = [
            .layerMaxXMaxYCorner
        ]
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(pressedConfirmBtn), for: .touchUpInside)
    }
    
    private let divider = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.tint.main.v400
    }
    
    private let dimmedView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.background.withAlphaComponent(0.7)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        screenName = "dialog"
        setViews()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    func setViews() {
        view.backgroundColor = .clear
        view.addSubview(dimmedView)
        view.addSubview(dialogView)
        dialogView.addSubview(dialogTitle)
        dialogView.addSubview(subDialogTitle)
        
        dialogTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.leading.equalToSuperview().offset(10)
            make.width.equalToSuperview().inset(10)
        }
        
        dialogView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(156)
        }
        
        subDialogTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(dialogTitle.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(10)
            make.width.equalToSuperview().inset(10)
        }
        
        dimmedView.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        setButtonLayout()
    }
    
    func setButtonLayout() {
        print("Dialog :: setButtonLaout = \(dialogSize)")
        switch dialogSize {
        case .small:
            subDialogTitle.isHidden = true
            dialogView.snp.updateConstraints { make in
                make.height.equalTo(156)
            }

        case .medium:
            subDialogTitle.isHidden = false
            subDialogTitle.numberOfLines = 1
            dialogView.snp.updateConstraints { make in
                make.height.equalTo(179)
            }

        case .large:
            subDialogTitle.isHidden = false
            subDialogTitle.numberOfLines = 2
            dialogView.snp.updateConstraints { make in
                make.height.equalTo(189)
            }
        }
        
        switch dialogButtonType {
        case .oneBtn:
            dialogView.addSubview(oneButton)
            oneButton.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalTo(52)
                make.bottom.equalToSuperview()
            }

        case .twoBtn:
            dialogView.addSubview(leftButton)
            dialogView.addSubview(rightButton)
            dialogView.addSubview(divider)
            
            leftButton.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.width.equalTo(140)
                make.height.equalTo(52)
                make.bottom.equalToSuperview()
            }
            
            divider.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.width.equalTo(1)
                make.centerY.equalTo(leftButton)
                make.height.equalTo(20)
            }
            
            rightButton.snp.makeConstraints { make in
                make.leading.equalTo(leftButton.snp.trailing)
                make.width.equalTo(140)
                make.height.equalTo(52)
                make.bottom.equalToSuperview()
            }
        }
        
        self.view.layoutIfNeeded()
    }
    
    func setText() {
        dialogTitle.text = titleText
        subDialogTitle.text = subTitleText
        subDialogTitle.setLineHeight(lineHeight: 1.14)
        leftButton.setTitle(cancleText, for: .normal)
        rightButton.setTitle(confirmText, for: .normal)
        oneButton.setTitle(confirmText, for: .normal)

        self.view.layoutIfNeeded()
    }
}

// MARK: - Action 처리
extension DialogViewController {
    @objc
    func pressedConfirmBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        self.dismiss(animated: true) {
            if let dialogScreen = self.dialogScreen {
                self.delegate?.action(dialogScreen: dialogScreen)
            }

            self.delegate = nil
        }
    }
    
    @objc
    func pressedCancelBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        self.dismiss(animated: true) {
            if let dialogScreen = self.dialogScreen {
                self.delegate?.exit(dialogScreen: dialogScreen)
            }
            self.delegate = nil
        }
    }
}

// MARK: - 재사용성
extension DialogDelegate where Self: UIViewController {
    public func showDialog(
        dialogScreen: DialogScreen,
        size: DialogSize,
        buttonType: DialogButtonType,
        titleText: String,
        subTitleText: String? = "",
        cancelButtonText: String? = "",
        confirmButtonText: String
    ) {
        let dialogViewController = DialogViewController()
        
        dialogViewController.delegate = self
        dialogViewController.dialogScreen = dialogScreen
        
        dialogViewController.modalPresentationStyle = .overFullScreen
        dialogViewController.modalTransitionStyle = .crossDissolve
        
        dialogViewController.dialogButtonType = buttonType
        dialogViewController.dialogSize = size
        dialogViewController.titleText = titleText
        dialogViewController.subTitleText = subTitleText ?? ""
        dialogViewController.confirmText = confirmButtonText
        dialogViewController.cancleText = cancelButtonText ?? ""
        dialogViewController.setButtonLayout()
        
        self.present(dialogViewController, animated: true, completion: nil)
    }
}
