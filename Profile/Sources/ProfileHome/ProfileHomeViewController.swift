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
import GoogleMobileAds

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
    
    // 구독/구매
    func pressedPurchaseCheckCell()
    func pressedPurchaseCell()
}

enum ProfileHomeSection: Int {
    case SETTING1 = 0
    case SETTING2 = 1
    case DEV
}

final class ProfileHomeViewController: UIViewController, ProfileHomePresentable, ProfileHomeViewControllable {
    
    var profileHomeDataArr_Setting1: [ProfileHomeModel] = [
        ProfileHomeModel(section: .SETTING1, type: .arrow, title: MenualString.profile_button_guide, actionName: "showGuide"),
        ProfileHomeModel(section: .SETTING1, type: .toggle, title: MenualString.profile_button_set_password, actionName: "setPassword"),
        ProfileHomeModel(section: .SETTING1, type: .arrow, title: MenualString.profile_button_change_password, actionName: "changePassword"),
    ]
    
    var profileHomeDataArr_Setting2: [ProfileHomeModel]  = [
        // profileHomeModel(section: .SETTING2, type: .arrow, title: "iCloud 동기화하기"),
        ProfileHomeModel(section: .SETTING2, type: .arrow, title: MenualString.profile_button_backup, actionName: "backup"),
        ProfileHomeModel(section: .SETTING2, type: .arrow, title: MenualString.profile_button_restore, actionName: "load"),
        ProfileHomeModel(section: .SETTING2, type: .arrow, title: MenualString.profile_button_mail, actionName: "mail"),
        ProfileHomeModel(section: .SETTING2, type: .arrow, title: MenualString.profile_button_openSource, actionName: "openSource"),
        // ProfileHomeModel(section: .SETTING2, type: .arrow, title: "개발자 도구"),
    ]
    
    var profileHomeDevDataArr: [ProfileHomeModel] = [
        ProfileHomeModel(section: .DEV, type: .arrow, title: "개발자 도구", actionName: "devTools"),
        ProfileHomeModel(section: .DEV, type: .arrow, title: "디자인 시스템", actionName: "designSystem"),
        ProfileHomeModel(section: .DEV, type: .arrow, title: "리뷰 요청", actionName: "review"),
        ProfileHomeModel(section: .DEV, type: .toggleWithDescription, title: "일기 작성 알림 설정하기", description: "일기를 꾸준히 쓸 수 있도록 알림을 보내드릴게요", actionName: "review"),
        ProfileHomeModel(section: .DEV, type: .arrow, title: "구독 확인", actionName: "storeCheck"),
        ProfileHomeModel(section: .DEV, type: .arrow, title: "결제하기", actionName: "storeBuy"),
        
    ]

    weak var listener: ProfileHomePresentableListener?
    private let disposeBag: DisposeBag = .init()

    private let naviView: MenualNaviView = .init(type: .myPage)
    private let settingTableView: UITableView = .init(frame: CGRect.zero, style: .grouped)
    private let admobView: GADBannerView = .init()
    
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
        configureUI()
        setViews()
        bind()
    }
    
    private func configureUI() {
        naviView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        }
        
        settingTableView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
            $0.contentInset = UIEdgeInsets(top: UIApplication.topSafeAreaHeight + 24, left: 0, bottom: 40, right: 0)
            $0.sectionHeaderHeight = 34
            $0.delegate = self
            $0.dataSource = self
            $0.register(ProfileHomeCell.self, forCellReuseIdentifier: "ProfileHomeCell")
            $0.rowHeight = UITableView.automaticDimension
            $0.estimatedRowHeight = 88
            $0.separatorStyle = .none
        }
        
        admobView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.adUnitID = ADUtil.profileHomeUnitID
            $0.rootViewController = self
            $0.load(GADRequest())
            $0.delegate = self
        }
    }
    
    func setViews() {
        self.view.addSubview(naviView)
        self.view.addSubview(settingTableView)
        self.view.addSubview(admobView)
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
        
        admobView.snp.makeConstraints { make in
            make.width.equalTo(GADAdSizeBanner.size.width)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(GADAdSizeBanner.size.height)
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
        _ = showToast(message: "메뉴얼 가져오기를 완료했어요")
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
            var count = profileHomeDataArr_Setting1.count ?? 0
            if listener?.isEnabledPasswordRelay.value ?? false == false {
                count -= 1
            }

            return count
            

        case .SETTING2:
            return profileHomeDataArr_Setting2.count

        case .DEV:
            if !DebugMode.isDebugMode { return 0 }
            return profileHomeDevDataArr.count
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
            guard let data = profileHomeDataArr_Setting1[safe: index] else { return UITableViewCell() }
            cell.title = data.title
            cell.desc = data.description
            cell.profileHomeCellType = data.type
            cell.switchIsOn = listener?.isEnabledPasswordRelay.value ?? false
            cell.actionName = data.actionName
            return cell

        case .SETTING2:
            guard let data = profileHomeDataArr_Setting2[safe: index] else { return UITableViewCell() }
            cell.title = data.title
            cell.desc = data.description
            cell.profileHomeCellType = data.type
            cell.actionName = data.actionName
            return cell
            
        case .DEV:
            if !DebugMode.isDebugMode { return UITableViewCell() }
            guard let data = profileHomeDevDataArr[safe: index] else { return UITableViewCell() }
            cell.title = data.title
            cell.profileHomeCellType = data.type
            cell.desc = data.description
            
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
            guard let data = profileHomeDataArr_Setting1[safe: index] else { return }

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
            guard let data = profileHomeDataArr_Setting2[safe: index] else { return }
            if data.title == MenualString.profile_button_openSource {
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
            guard let data = profileHomeDevDataArr[safe: index] else { return }
            if data.title == "개발자 도구" {
                print("ProfileHome :: 개발자 도구 호출!")
                listener?.pressedProfileDeveloperCell()
            } else if data.title == "디자인 시스템" {
                print("ProfileHome :: 디자인 시스템 호출!")
                listener?.pressedDesignSystemCell()
            } else if data.title == "리뷰 요청" {
                listener?.pressedReviewCell()
            } else if data.title == "구독 확인" {
                listener?.pressedPurchaseCheckCell()
            }  else if data.title == "결제하기" {
                listener?.pressedPurchaseCell()
            } else if data.title == "일기 작성 알림 설정하기" {
                
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - MessageUI
extension ProfileHomeViewController: MFMailComposeViewControllerDelegate {
    func pressedDeveloperQACell() {
        if MFMailComposeViewController.canSendMail() {
            let composeViewController = MFMailComposeViewController()
            composeViewController.mailComposeDelegate = self
            
            let bodyString = """
                             Q. 메뉴얼을 사용해주셔서 감사합니다. 어떤 주제의 문의사항 인가요? ( 불편접수, 질문사항, 오류제보, 기타 등등 )

                             :

                             Q. 내용을 간단히 설명해 주세요. 사진을 첨부해주셔도 좋습니다.

                             :

                             문의해주셔서 감사합니다. 빠른 시일 내 조치하여 업데이트 하도록 하겠습니다.
                             
                             -------------------
                             
                             Device Model : \(DeviceUtil.getDeviceIdentifier())
                             Device OS : \(UIDevice.current.systemVersion)
                             App Version : \(DeviceUtil.getCurrentVersion())
                             
                             -------------------
                             """
            
            composeViewController.setToRecipients(["jjikkyu@naver.com"])
            composeViewController.setSubject("<메뉴얼> 개발자에게 문의하기")
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
}

// MARK: - UIDocumentPickerDelegate
extension ProfileHomeViewController: UIDocumentPickerDelegate {
    
}

// MARK: - GoogleAds Delegate
extension ProfileHomeViewController: GADBannerViewDelegate {
    
}

@available(iOS 17.0, *)
#Preview {
    let vc = ProfileHomeViewController()
    return vc
}
