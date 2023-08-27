//
//  DiaryBottomSheetViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import RIBs
import RxSwift
import SnapKit
import RxRelay
import UIKit
import FirebaseAnalytics
import MenualEntity
import DesignSystem
import MenualUtil

public enum MenualBottomSheetRightBtnType {
    case close
    case check
}

public enum MenualBottomSheetRightBtnIsActivate {
    case activate
    case unActivate
    case _default
}

public enum MenualBottomSheetType {
    case menu
    case calender
    case reminder
    case filter
    case review
    case alarm
}

public protocol DiaryBottomSheetPresentableListener: AnyObject {
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { get }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { get }
    var isHideMenualRelay: BehaviorRelay<Bool>? { get }
    
    func pressedCloseBtn()
    func pressedWriteBtn()
    
    // MenualBottomSheetMenuComponentView
    var menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>? { get set }
    
    func filterWithWeatherPlacePressedFilterBtn()
    
    // MenualBottomSheetReminderComponentView
    func reminderCompViewshowToast(type: ReminderToastType)
    func reminderCompViewSetReminder(isEditing: Bool, requestDateComponents: DateComponents, requestDate: Date)
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { get }
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { get }
    
    // ReviewComponentView
    func pressedReviewBtn()
    func pressedInquiryBtn()
    
    // AlarmComponentView
    func getCurrentNotifications() async -> [Weekday]
    func getCurrentNotificationTime() async -> Date?
    func pressedAlarmConfirmBtn(date: Date, days: [Weekday])
}

final class DiaryBottomSheetViewController: UIViewController, DiaryBottomSheetPresentable, DiaryBottomSheetViewControllable {
    
    weak var listener: DiaryBottomSheetPresentableListener?
    var disposeBag = DisposeBag()
    var keyHeight: CGFloat?
    public var bottomSheetHeight: CGFloat = 400
    
    var bottomSheetTitle: String = "" {
        didSet { layoutUpdate() }
    }
    
    var menualBottomSheetRightBtnType: MenualBottomSheetRightBtnType = .close {
        didSet { layoutUpdate() }
    }
    
    var menualBottomSheetRightBtnIsActivate: MenualBottomSheetRightBtnIsActivate = .unActivate {
        didSet { layoutUpdate() }
    }
    
    var menualBottomSheetType: MenualBottomSheetType = .menu {
        didSet { menualBottomSheetTypeLayoutUpdate() }
    }
    
    lazy private var dimmedView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.background.withAlphaComponent(0.7)
        $0.alpha = 0
        
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        $0.addGestureRecognizer(dimmedTap)
        $0.isUserInteractionEnabled = true
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = Colors.grey.g100
        $0.text = "날씨를 선택해 주세요"
    }
    
    lazy var addBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitle("날씨 추가하기", for: .normal)
        $0.addTarget(self, action: #selector(pressedAddBtn), for: .touchUpInside)
        $0.setTitleColor(Colors.grey.g800, for: .normal)
        $0.backgroundColor = Colors.tint.sub.n400
        $0.AppCorner(.tiny)
    }
    
    var rightBtn = BaseButton().then {
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.isHidden = true
    }
    
    let divider = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g700
    }
    
    let bottomSheetView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
    }
    
    // 메뉴 컴포넌트
    private lazy var menuComponentView = MenualBottomSheetMenuComponentView().then {
        $0.categoryName = "menu"
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.isHidden = true
        $0.editMenuBtn.addTarget(self, action: #selector(pressedEditBtn), for: .touchUpInside)
        $0.deleteMenuBtn.addTarget(self, action: #selector(pressedDeleteBtn), for: .touchUpInside)
        $0.hideMenuBtn.addTarget(self, action: #selector(pressedHideMenuBtn), for: .touchUpInside)
    }
    
    // 필터 컴포넌트
    private lazy var filterComponentView = MenualBottomSheetFilterComponentView().then {
        $0.categoryName = "filter"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.bind()
        $0.isHidden = true
        $0.filterBtn.addTarget(self, action: #selector(pressedFilterBtn), for: .touchUpInside)
    }
    
    // 리마인더 컴포넌트
    private lazy var reminderComponentView = MenualBottomSheetReminderComponentView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.delegate = self
    }
    
    // 리뷰 컴포넌트
    private lazy var reviewComponentView = MenualBottomSheetReviewComponentView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.delegate = self
    }
    
    // 다시알람 컴포넌트
    private var alarmComponentView: MenualBottomSheetAlarmComponentView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setViews()
        bottomSheetView.backgroundColor = Colors.background
        
        isModalInPresentation = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showBottomSheet()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // super.delegate = nil
//        weatherPlaceSelectView.delegate = nil
        filterComponentView.delegate = nil
        reminderComponentView.delegate = nil
        // listener?.pressedCloseBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        // showBottomSheet()
    }
    
    func setViews() {
        // 기본 컴포넌트 SetViews
        view.addSubview(dimmedView)
        view.addSubview(bottomSheetView)
        bottomSheetView.addSubview(titleLabel)
        bottomSheetView.addSubview(rightBtn)
        bottomSheetView.addSubview(divider)
        
        dimmedView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        bottomSheetView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().inset(26)
            make.height.equalTo(20)
        }
        
        rightBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(24)
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(2)
        }
    }

    
    @objc
    func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
         hideBottomSheetAndGoBack()
         resignFirstResponder()
    }
    
    func setViews(type: MenualBottomSheetType) async {
        setViews()
        print("DiaryBottomSheet :: menualBottomSheetType = \(type)")
        menualBottomSheetType = type
        
        switch menualBottomSheetType {
        case .reminder:
            bottomSheetView.addSubview(reminderComponentView)
            reminderComponentView.snp.makeConstraints { make in
                make.top.equalTo(self.divider.snp.bottom).offset(16)
                make.leading.equalToSuperview().offset(24)
                make.width.equalToSuperview().inset(24)
                make.height.equalTo(488)
                // make.bottom.equalToSuperview().inset(35)
            }
            
            bottomSheetTitle = MenualString.reminder_title
            reminderComponentView.isHidden = false
            menualBottomSheetRightBtnType = .close
            rightBtn.actionName = "close"
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .menu:
            bottomSheetView.addSubview(menuComponentView)
            menuComponentView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.width.equalToSuperview().inset(20)
                make.top.equalTo(self.divider.snp.bottom).offset(20)
            }

            bottomSheetTitle = MenualString.menu_title
            print("DiaryBottomSheet :: 메뉴입니다.")
            menuComponentView.isHidden = false
            menualBottomSheetRightBtnType = .close
            rightBtn.actionName = "close"
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .filter:
            bottomSheetView.addSubview(filterComponentView)
            filterComponentView.snp.makeConstraints { make in
                make.leading.width.equalToSuperview()
                make.top.equalTo(self.divider.snp.bottom).offset(27)
                make.height.equalTo(260)
            }

            bottomSheetTitle = MenualString.filter_title
            filterComponentView.isHidden = false
            menualBottomSheetRightBtnType = .close
            rightBtn.actionName = "close"
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .calender:
            bottomSheetTitle = MenualString.filter_title_date
            
        case .review:
            bottomSheetView.addSubview(reviewComponentView)
            reviewComponentView.isHidden = false
            divider.isHidden = true
            reviewComponentView.snp.makeConstraints { make in
                make.leading.width.equalToSuperview()
                make.top.equalTo(self.rightBtn.snp.bottom)
                make.height.equalTo(622)
            }
            menualBottomSheetRightBtnType = .close
            rightBtn.actionName = "close"
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .alarm:
            let currentNotifications: [Weekday]? = await listener?.getCurrentNotifications()
            let currentNotificationTime: Date? = await listener?.getCurrentNotificationTime()

            let alarmComponentView: MenualBottomSheetAlarmComponentView = .init(
                currentWeekdays: currentNotifications,
                currentTime: currentNotificationTime
            )
            alarmComponentView.deleagete = self

            self.alarmComponentView = alarmComponentView
            bottomSheetView.addSubview(alarmComponentView)
            alarmComponentView.isHidden = false
            alarmComponentView.snp.makeConstraints { make in
                make.leading.width.equalToSuperview()
                make.top.equalTo(self.divider.snp.bottom).offset(24)
                make.height.equalTo(434)
            }
            bottomSheetTitle = "알림 시간 설정"
            menualBottomSheetRightBtnType = .close
            rightBtn.actionName = "close"
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
        }
    }
    
    func layoutUpdate() {
        titleLabel.text = bottomSheetTitle
        
        switch menualBottomSheetRightBtnType {
        case .close:
            rightBtn.tintColor = Colors.grey.g200
            rightBtn.isHidden = false
            rightBtn.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
            
            switch menualBottomSheetRightBtnIsActivate {
            // Close 버튼은 항상 활성화 되어 있어야 하므로 항상 true
            case .unActivate, ._default:
                rightBtn.tintColor = Colors.grey.g200
                rightBtn.isUserInteractionEnabled = true
                
            case .activate:
                rightBtn.tintColor = Colors.tint.sub.n400
                rightBtn.isUserInteractionEnabled = true
            }
            
        case .check:
            rightBtn.isHidden = false
            rightBtn.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
            
            switch menualBottomSheetRightBtnIsActivate {
            case .unActivate:
                rightBtn.tintColor = Colors.grey.g600
                rightBtn.isUserInteractionEnabled = false
                
            case .activate:
                rightBtn.tintColor = Colors.tint.sub.n400
                rightBtn.isUserInteractionEnabled = true
                
            case ._default:
                rightBtn.tintColor = Colors.grey.g600
                rightBtn.isUserInteractionEnabled = true
            }
        }
    }
}

// MARK: - MenualBottomSheetBaseDelegate
extension DiaryBottomSheetViewController {
    // 부모 뷰가 애니메이션이 모두 끝났을 경우 Delegate 전달 받으면 그때 Router에서 RIB 해제
    func dismissedBottomSheet() {
        print("DiaryBottomSheet :: 이때 라우터 호출할래?")
        listener?.pressedCloseBtn()
    }
}

// MARK: - IBAction
extension DiaryBottomSheetViewController {
    @objc func keyboardWillShow(_ sender: Notification) {
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        keyHeight = keyboardHeight

        self.view.frame.size.height -= keyboardHeight
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        guard let keyHeight = keyHeight else {
            return
        }

        self.view.frame.size.height += keyHeight
    }
    
    @objc
    func pressedAddBtn() {
        print("TODO :: pressedAddBtn!!")
        // super.delegate = nil
//        weatherPlaceSelectView.delegate = nil

        hideBottomSheetAndGoBack()
        resignFirstResponder()
        listener?.pressedWriteBtn()
    }
    
    @objc
    func closeBottomSheet(_ button: UIButton) {
        MenualLog.logEventAction(responder: button, parameter: ["type": menualBottomSheetType])
        hideBottomSheetAndGoBack()
    }
}

// MARK: - Bottom Sheet 기본 컴포넌트
extension DiaryBottomSheetViewController {
    func hideBottomSheetAndGoBack() {
        bottomSheetView.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.bottom)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.dimmedView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { [weak self] isShow in
            guard let self = self else { return }
            print("DiaryBottomSheet :: isHide!")
            // self.delegate?.dismissedBottomSheet()
            self.dismissedBottomSheet()
        }
    }
    
    func showBottomSheet() {
        let safeAreaHeight: CGFloat = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding: CGFloat = view.safeAreaInsets.bottom
        print("DiaryBottomSheet :: safeAreaHeight = \(safeAreaHeight), bottomPadding = \(bottomPadding)")
        bottomSheetView.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom).inset(bottomSheetHeight)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.dimmedView.alpha = 0.1
            self.view.layoutIfNeeded()
        } completion: { isShow in
            print("DiaryBottomSheet :: bottomSheet isShow!")
        }
    }
    
    func menualBottomSheetTypeLayoutUpdate() {
        print("!!! \(menualBottomSheetType)")
        switch menualBottomSheetType {
        case .calender:
            bottomSheetTitle = MenualString.filter_title_date
            bottomSheetHeight = 375
            
        case .filter:
            bottomSheetTitle = MenualString.filter_title
            bottomSheetHeight = 392
            
        case .menu:
            bottomSheetTitle = MenualString.menu_title
            bottomSheetHeight = 328
            
        case .reminder:
            bottomSheetTitle = MenualString.reminder_title
            bottomSheetHeight = 622
            
        case .review:
            bottomSheetTitle = ""
            bottomSheetHeight = 622
            
        case .alarm:
            bottomSheetTitle = "알림 시간 설정"
            bottomSheetHeight = 553
        }
    }

}

// MARK: - MenualBottomSheetMenulComponentView
extension DiaryBottomSheetViewController {
    func setHideBtnTitle(isHide: Bool) {
        print("DiaryBottomSheet :: setHideBtnTitle = \(isHide)")
        menuComponentView.isHide = isHide
    }
}

// MARK: - MenualBottomSheetFilterComponentView
extension DiaryBottomSheetViewController: MenualBottomSheetFilterComponentDelegate {
    var filterWeatherSelectedArrRelay: BehaviorRelay<[Weather]>? {
        listener?.filteredWeatherArrRelay
    }
    
    var filterPlaceSelectedArrRelay: BehaviorRelay<[Place]>? {
        listener?.filteredPlaceArrRelay
    }
    
    @objc
    func pressedFilterBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        listener?.filterWithWeatherPlacePressedFilterBtn()
    }
    
    func setFilterBtnCount(count: Int) {
        filterComponentView.filteredCount = count
    }
}

// MARK: - Debugging
extension DiaryBottomSheetViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
    }
}

// MARK: - MenualBottomSheetMenuComponentView
extension DiaryBottomSheetViewController {
    @objc
    func pressedHideMenuBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        print("DiaryBottomSheet :: pressedHideMenuBtn")
        let isHide = listener?.isHideMenualRelay?.value ?? false
        var titleText: String = ""
        switch isHide {
        case true:
            titleText = "숨긴 메뉴얼을 보시겠어요?"
        case false:
            titleText = "이 메뉴얼을 숨기시겠어요?"
        }

        showDialog(
            dialogScreen: .diaryBottomSheet(.hide),
             size: .small,
             buttonType: .twoBtn,
             titleText: titleText,
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
    }
    
    @objc
    func pressedEditBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        print("DiaryBottomSheet :: pressedEditBtn")
        listener?.menuComponentRelay?.accept(.edit)
    }
    
    @objc
    func pressedDeleteBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        print("DiaryBottomSheet :: pressedDeleteBtn")
        showDialog(
             dialogScreen: .diaryBottomSheet(.diaryDelete),
             size: .small,
             buttonType: .twoBtn,
             titleText: "해당 메뉴얼을 삭제하시겠어요?",
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
    }
}

// MARK: - ReminderComponentView
extension DiaryBottomSheetViewController: MenualBottomSheetReminderComponentViewDelegate {
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? {
        listener?.isEnabledReminderRelay
    }
    
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? {
        listener?.reminderRequestDateRelay
    }
    
    func pressedSelectBtn(type: ReminderToastType, requestDateComponents: DateComponents, requestDate: Date) {
        switch isEditing {
        case true:
            print("DiaryBottomSheet :: 수정모드 이므로 팝업 띄웁니다")

        case false:
            print("DiaryBottomSheet :: 새로 등록하므로 팝업 안띄웁니다.")
        }
        
        listener?.reminderCompViewshowToast(type: type)
        let isEditing: Bool = type == .edit ? true : false
        
        let model = ReminderRequsetModel(
            isEditing: isEditing,
            requestDateComponents: requestDateComponents,
            requestDate: requestDate
        )
        listener?.reminderRequestDateRelay?.accept(model)
        hideBottomSheetAndGoBack()
    }
    
    func isNeedReminderAuthorization() {
        showDialog(
            dialogScreen: .diaryBottomSheet(.reminderAuth),
            size: .large,
            buttonType: .twoBtn,
            titleText: MenualString.alarm_alert_authorization_title,
            subTitleText: MenualString.alarm_alert_authorization_subtitle,
            cancelButtonText: MenualString.alarm_alert_cancel,
            confirmButtonText: MenualString.alarm_alert_confirm
        )
    }
    
    func setCurrentReminderData(isEnabled: Bool, dateComponets: DateComponents?) {
        print("DiaryBottomSheet :: setCurrentReminderData! => isEnabled = \(isEnabled), dateComponents = \(dateComponets)")
        switch isEnabled {
        case true:
            // reminderComponentView.selectedSwitchBtn()
            reminderComponentView.dateComponets = dateComponets
            // reminderComponentView.switchBtn.sendActions(for: .touchUpInside)
            
        case false:
            // reminderComponentView.switchBtn.isOn = false
            // reminderComponentView.dateComponets = dateComponets
            break
            
        }
    }
    
    func pressedIsEnabledSwitchBtn(isEnabled: Bool) {
        showDialog(
             dialogScreen: .diaryBottomSheet(.reminderEnable),
             size: .small,
             buttonType: .twoBtn,
             titleText: MenualString.reminder_alert_title_reminder_clear,
             cancelButtonText: MenualString.reminder_alert_cancel,
             confirmButtonText: MenualString.reminder_alert_confirm_reminder
        )
    }
}

// MARK: - Dialog
extension DiaryBottomSheetViewController: DialogDelegate {
    func action(dialogScreen: DesignSystem.DialogScreen) {
        if case .diaryBottomSheet(let diaryBottomSheetDialog) = dialogScreen {
            switch diaryBottomSheetDialog {
            case .reminderEnable:
                listener?.reminderCompViewshowToast(type: .delete)
                listener?.isEnabledReminderRelay?.accept(false)
                hideBottomSheetAndGoBack()
                
            case .hide:
                listener?.menuComponentRelay?.accept(.hide)
                hideBottomSheetAndGoBack()
                
            case .diaryDelete:
                listener?.menuComponentRelay?.accept(.delete)
                hideBottomSheetAndGoBack()
                
            case .reminderAuth:
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    func exit(dialogScreen: DesignSystem.DialogScreen) {
        if case .diaryBottomSheet(let diaryBottomSheetDialog) = dialogScreen {
            switch diaryBottomSheetDialog {
            case .reminderEnable:
                break
                
            case .hide:
                hideBottomSheetAndGoBack()
                
            case .diaryDelete:
                hideBottomSheetAndGoBack()
                
            case .reminderAuth:
                break
            }
        }
    }
}

// MARK: - ReviewComponenet

extension DiaryBottomSheetViewController: MenualBottomSheetReviewComponentViewDelegate {
    func goReviewPage() {
        let appID = "1617404636" // 앱스토어 Connect에서 확인 가능한 앱 ID를 입력하세요.
        let reviewURL = "https://itunes.apple.com/app/id\(appID)?action=write-review"
        if let url = URL(string: reviewURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func pressedPraiseBtn() {
        listener?.pressedReviewBtn()
    }
    
    func pressedInquiryBtn() {
        listener?.pressedInquiryBtn()
    }
}

// MARK: - Alarmcomponent

extension DiaryBottomSheetViewController: AlarmComponentDelegate {
    func pressedConfirmBtn(date: Date, days: [Weekday]) {
        listener?.pressedAlarmConfirmBtn(date: date, days: days)
    }
}
