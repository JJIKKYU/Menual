//
//  ProfileHomeViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import RIBs
import RxSwift
import UIKit
import SnapKit
import RxRelay
import MessageUI
import DesignSystem
import MenualUtil

protocol ProfileHomePresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
    var profileHomeDataArr_Setting1: [ProfileHomeModel] { get }
    var profileHomeDataArr_Setting2: [ProfileHomeModel] { get }
    var profileHomeDevDataArr: [ProfileHomeModel] { get }
    
    // ProfilePassword
    func pressedProfilePasswordCell()
    func pressedProfilePasswordChangeCell()
    
    // ProfileDeveloper
    func pressedProfileDeveloperCell()
    var isEnabledPasswordRelay: BehaviorRelay<Bool> { get }
    
    // ProfileOpensource
    func pressedProfileOpensourceCell()
    
    // ProfileRestore
    func pressedProfileRestoreCell()
    
    // ProfileBackup
    func pressedProfileBackupCell()
    
    // ProfileDesignSystem
    func pressedDesignSystemCell()
    
    // 리뷰 요청
    func pressedReviewCell()
}

enum ProfileHomeSection: Int {
    case SETTING1 = 0
    case SETTING2 = 1
    case DEV
}

final class ProfileHomeViewController: UIViewController, ProfileHomePresentable, ProfileHomeViewControllable {

    weak var listener: ProfileHomePresentableListener?
    private let disposeBag = DisposeBag()

    lazy var naviView = MenualNaviView(type: .myPage).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
    }
    
    lazy var settingTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: UIApplication.topSafeAreaHeight + 24, left: 0, bottom: 0, right: 0)
        $0.sectionHeaderHeight = 34
        $0.delegate = self
        $0.dataSource = self
        $0.register(ProfileHomeCell.self, forCellReuseIdentifier: "ProfileHomeCell")
        $0.rowHeight = 56
        $0.separatorStyle = .none
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
        
        // 뒤로가기 제스쳐 가능하도록
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        setViews()
        bind()
    }
    
    func setViews() {
        self.view.addSubview(naviView)
        self.view.addSubview(settingTableView)
        self.view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        settingTableView.snp.makeConstraints { make in
            make.leading.width.top.bottom.equalToSuperview()
        }
    }
    
    func bind() {
        listener?.isEnabledPasswordRelay
            .subscribe(onNext: { [weak self] isEnabledPassword in
                guard let self = self else { return }
                print("ProfileHome :: isEnabledPasswordRelay = \(isEnabledPassword)")
                DispatchQueue.main.async {
                    self.settingTableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MenualLog.logEventAction("profile_appear")
    }
    
    @objc
    func pressedBackBtn() {
        print("ProfileHomeVC :: pressedBackBtn!")
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
    
    func showToastRestoreSuccess() {
        showToast(message: "메뉴얼 가져오기를 완료했어요")
    }
}

// MARK: - IBaction
extension ProfileHomeViewController {
    @objc
    func selectedSwitchBtn(_ sender: UISwitch) {
        print("!!")
        switch sender.isOn {
        case true:
            print("isOn!")
        case false:
            print("isOff!")
        }
    }
}

// MARK: - UITableView
extension ProfileHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // 디버그 모드가 아닐 경우에는 2개만 노출
        if !DebugMode.isDebugMode {
            return 2
        }
        
        // 디버그 모드일 경우에는 개발자 도구도 함께 노출
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        print("sectionNumber = \(section)")
        let headerView = ListHeader(type: .datepageandicon, rightIconType: .none)
        let divider = Divider(type: ._2px)
        headerView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.top).offset(32)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(2)
        }

        guard let sections = ProfileHomeSection(rawValue: section) else { return UIView() }
        
        switch sections {
        case .SETTING1:
            headerView.title = "메뉴얼 설정"
            return headerView

        case .SETTING2:
            headerView.title = "기타"
            return headerView

        case .DEV:
            if !DebugMode.isDebugMode { return UIView() }
            headerView.title = "개발자 도구"
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = ProfileHomeSection(rawValue: section) else { return 0 }
        switch sections {
        case .SETTING1:
            var count = listener?.profileHomeDataArr_Setting1.count ?? 0
            if listener?.isEnabledPasswordRelay.value ?? false == false {
                count -= 1
            }

            return count
            

        case .SETTING2:
            return listener?.profileHomeDataArr_Setting2.count ?? 0

        case .DEV:
            if !DebugMode.isDebugMode { return 0 }
            return listener?.profileHomeDevDataArr.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHomeCell", for: indexPath) as? ProfileHomeCell else { return UITableViewCell() }
        let index = indexPath.row
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = true
        let section = indexPath.section
        
        guard let sections = ProfileHomeSection(rawValue: section) else { return UITableViewCell() }
        switch sections {
        case .SETTING1:
            guard let data = listener?.profileHomeDataArr_Setting1[safe: index] else { return UITableViewCell() }
            cell.title = data.title
            cell.profileHomeCellType = data.type
            cell.switchIsOn = listener?.isEnabledPasswordRelay.value ?? false
            cell.actionName = data.actionName
            return cell

        case .SETTING2:
            guard let data = listener?.profileHomeDataArr_Setting2[safe: index] else { return UITableViewCell() }
            cell.title = data.title
            cell.profileHomeCellType = data.type
            cell.actionName = data.actionName
            return cell
            
        case .DEV:
            if !DebugMode.isDebugMode { return UITableViewCell() }
            guard let data = listener?.profileHomeDevDataArr[safe: index] else { return UITableViewCell() }
            cell.title = data.title
            cell.profileHomeCellType = data.type
            
            cell.actionName = data.actionName
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ProfileHomeCell else { return }
        MenualLog.logEventAction(responder: cell)

        let section = indexPath.section
        let index = indexPath.row
        print("ProfileHome :: indexpath = \(indexPath)")

        guard let sections = ProfileHomeSection(rawValue: section) else { return }
        switch sections {
        case .SETTING1:
            guard let data = listener?.profileHomeDataArr_Setting1[safe: index] else { return }

            if data.title == MenualString.profile_button_set_password {
                print("ProfileHome :: 비밀번호 설정하기")
                // cell.switchIsOn = !cell.switchIsOn
                // cell.switchBtn.isOn = listener?.isEnabledPasswordRelay.value ?? false
                listener?.pressedProfilePasswordCell()
            } else if data.title == MenualString.profile_button_change_password {
                listener?.pressedProfilePasswordChangeCell()
            } else if data.title == MenualString.profile_button_guide {
                //사파리로 링크열기
                if let url = URL(string: "https://hill-license-fb3.notion.site/589e7606d7f642378d11a94ea0344cfd") {
                    UIApplication.shared.open(url, options: [:])
                }
            }

        case .SETTING2:
            guard let data = listener?.profileHomeDataArr_Setting2[safe: index] else { return }
            if data.title == "개발자 도구" {
                print("ProfileHome :: 개발자 도구 호출!")
                listener?.pressedProfileDeveloperCell()
            } else if data.title == MenualString.profile_button_openSource {
                print("ProfileHome :: 오픈 소스 라이브러리 보기 호출!")
                listener?.pressedProfileOpensourceCell()
            } else if data.title == MenualString.profile_button_mail {
                self.pressedDeveloperQACell()
            } else if data.title == "iCloud 동기화하기" {
                print("ProfileHome :: iCloud 동기화하기!")
            } else if data.title == MenualString.profile_button_backup {
                print("ProfileHome :: backup!")
                listener?.pressedProfileBackupCell()
            } else if data.title == MenualString.profile_button_restore {
                print("ProfileHome :: restore")
                listener?.pressedProfileRestoreCell()
            }
            
        case .DEV:
            guard let data = listener?.profileHomeDevDataArr[safe: index] else { return }
            if data.title == "디자인 시스템" {
                print("ProfileHome :: 디자인 시스템 호출!")
                listener?.pressedDesignSystemCell()
            } else if data.title == "리뷰 요청" {
                listener?.pressedReviewCell()
            }
            
        }
    }
}

// MARK: - MessageUI
extension ProfileHomeViewController: MFMailComposeViewControllerDelegate {
    func pressedDeveloperQACell() {
        print("ProfileHome :: 개발자에게 문의하기!")
        if MFMailComposeViewController.canSendMail() {
            let composeViewController = MFMailComposeViewController()
            composeViewController.mailComposeDelegate = self
            
            let bodyString = """
                             이곳에 내용을 작성해주세요.
                             
                             오타 발견 문의 시 아래 양식에 맞춰 작성해주세요.
                             
                             <예시>
                             글귀 ID : 글귀 4 (글귀 클릭 시 상단에 표시)
                             수정 전 : 실수해도 되.
                             수정 후 : 실수해도 돼.
                             
                             -------------------
                             
                             Device Model : \(self.getDeviceIdentifier())
                             Device OS : \(UIDevice.current.systemVersion)
                             App Version : \(self.getCurrentVersion())
                             
                             -------------------
                             """
            
            composeViewController.setToRecipients(["jjikkyu@naver.com"])
            composeViewController.setSubject("<메뉴얼> 문의 및 의견")
            composeViewController.setMessageBody(bodyString, isHTML: false)
            
            self.present(composeViewController, animated: true, completion: nil)
        } else {
            print("메일 보내기 실패")
            let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패", message: "메일을 보내려면 'Mail' 앱이 필요합니다. App Store에서 해당 앱을 복원하거나 이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
            let goAppStoreAction = UIAlertAction(title: "App Store로 이동하기", style: .default) { _ in
                // 앱스토어로 이동하기(Mail)
                if let url = URL(string: "https://apps.apple.com/kr/app/mail/id1108187098"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            let cancleAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
            
            sendMailErrorAlert.addAction(goAppStoreAction)
            sendMailErrorAlert.addAction(cancleAction)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Device Identifier 찾기
    func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }

    // 현재 버전 가져오기
    func getCurrentVersion() -> String {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else { return "" }
        return version
    }
}

// MARK: - UIDocumentPickerDelegate
extension ProfileHomeViewController: UIDocumentPickerDelegate {
    
}
