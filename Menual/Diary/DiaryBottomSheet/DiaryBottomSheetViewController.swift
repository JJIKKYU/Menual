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

enum MenualBottomSheetRightBtnType {
    case close
    case check
}

enum MenualBottomSheetRightBtnIsActivate {
    case activate
    case unActivate
    case _default
}

enum MenualBottomSheetType {
    case menu
    case calender
    case reminder
    case filter
    case dateFilter
}

protocol DiaryBottomSheetPresentableListener: AnyObject {
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { get }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { get }
    var isHideMenualRelay: BehaviorRelay<Bool>? { get }
    
    func pressedCloseBtn()
    func pressedWriteBtn()
    
    // MenualBottomSheetMenuComponentView
    var menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>? { get set }
    
    func filterWithWeatherPlacePressedFilterBtn()
    func filterDatePressedFilterBtn(yearDateFormatString: String)
    
    // MenualBottomSheetReminderComponentView
    func reminderCompViewshowToast(isEding: Bool)
    func reminderCompViewSetReminder(isEditing: Bool, requestDateComponents: DateComponents, requestDate: Date)
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { get }
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { get }
    
    var dateFilterModelRelay: BehaviorRelay<[DateFilterModel]?>? { get }
    // var filteredDiaryCountRelay: BehaviorRelay<Int>? { get set }
}

final class DiaryBottomSheetViewController: UIViewController, DiaryBottomSheetPresentable, DiaryBottomSheetViewControllable {

    weak var listener: DiaryBottomSheetPresentableListener?
    var disposeBag = DisposeBag()
    var keyHeight: CGFloat?
    public var bottomSheetHeight: CGFloat = 400
    
    // Filter 선택시 필터링된 메뉴얼 개수 넘겨주는 Relay
    var filteredMenaulCountsRelay = BehaviorRelay<Int>(value: 0)
    
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
//        $0.isUserInteractionEnabled = false
        $0.delegate = self
        $0.bind()
        $0.isHidden = true
        $0.filterBtn.addTarget(self, action: #selector(pressedFilterBtn), for: .touchUpInside)
        // $0.delegate = self
    }
    
    // 날짜 필터 컴포넌트
    private lazy var dateFilterComponentView = MenualDateFilterComponentView().then {
        $0.categoryName = "dateFilter"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.prevMonthArrowBtn.addTarget(self, action: #selector(pressedPrevMonthBtn), for: .touchUpInside)
        $0.nextMonthArrowBtn.addTarget(self, action: #selector(pressedNextMonthBtn), for: .touchUpInside)
        $0.prevYearArrowBtn.addTarget(self, action: #selector(pressedPrevYearBtn), for: .touchUpInside)
        $0.nextYearArrowBtn.addTarget(self, action: #selector(pressedNextYearBtn), for: .touchUpInside)
        $0.filterBtn.addTarget(self, action: #selector(pressedDateFilterBtn), for: .touchUpInside)
        $0.isHidden = true
    }
    
    // 리마인더 컴포넌트
    private lazy var reminderComponentView = MenualBottomSheetReminderComponentView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.delegate = self
    }
    
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

        // showBottomSheet()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // super.delegate = nil
//        weatherPlaceSelectView.delegate = nil
        filterComponentView.delegate = nil
        reminderComponentView.delegate = nil
        dateFilterComponentView.delegate = nil
        // listener?.pressedCloseBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        showBottomSheet()
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
    
    func setViews(type: MenualBottomSheetType) {
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
            
        case .dateFilter:
            bottomSheetView.addSubview(dateFilterComponentView)
            dateFilterComponentView.snp.makeConstraints { make in
                make.top.equalTo(self.divider.snp.bottom).offset(64)
                make.leading.equalToSuperview().offset(20)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(260)
            }

            bottomSheetTitle = MenualString.filter_title_date
            dateFilterComponentView.isHidden = false
            menualBottomSheetRightBtnType = .close
            rightBtn.actionName = "close"
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .calender:
            bottomSheetTitle = MenualString.filter_title_date
            
        
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
            
        case .filter, .dateFilter:
            bottomSheetTitle = MenualString.filter_title
            bottomSheetHeight = 392
            
        case .menu:
            bottomSheetTitle = "메뉴"
            bottomSheetHeight = 328
            
        case .reminder:
            bottomSheetTitle = "리마인더 알림"
            bottomSheetHeight = 622
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
    
    var filteredMenaulCountsObservable: Observable<Int> {
        return filteredMenaulCountsRelay.asObservable()
    }
    
    @objc
    func pressedFilterBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        listener?.filterWithWeatherPlacePressedFilterBtn()
    }
    
    func setFilterBtnCount(count: Int) {
        filterComponentView.filteredCount = count
    }
    
    func setCurrentFilteredBtn(weatherArr: [Weather], placeArr: [Place]) {
        print("DiaryBottomSheet :: setCurrentFilteredBtn, weatherArr = \(weatherArr), placeArr = \(placeArr)")
        filterComponentView.setBindRelay()
        // listener?.weatherFilterSelectedArrRelay.accept(weatherArr)
        // filterComponentView.setCurrentFilterBtn(weatherArr: weatherArr, placeArr: placeArr)
        // filterComponentView.placeSelectedArr = placeArr
        // filterComponentView.placeSelectedArr
        // filterComponentView.delegate?.filterPlaceSelectedArrRelay
        // filterComponentView.placeSelectedArr = placeArr
        //filterComponentView.weatherse
        // listener?.placeFilterSelectedArrRelay.accept(placeArr)
    }
}

// MARK: - MenualBottomSheetDateFilterComponentView
extension DiaryBottomSheetViewController: MenualDateFilterComponentDelegate {
    var dateFilterModelRelay: BehaviorRelay<[DateFilterModel]?>? {
        listener?.dateFilterModelRelay
    }

    @objc
    func pressedPrevMonthBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        let currentIdx = dateFilterComponentView.monthArrowIdxRelay.value
        dateFilterComponentView.monthArrowIdxRelay.accept(currentIdx - 1)
    }
    
    @objc
    func pressedNextMonthBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        let currentIdx = dateFilterComponentView.monthArrowIdxRelay.value
        dateFilterComponentView.monthArrowIdxRelay.accept(currentIdx + 1)
    }
    
    @objc
    func pressedPrevYearBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        print("DiaryBottomSheet :: pressedPrevYearBtn!")
        let currentIdx = dateFilterComponentView.yearArrowIdxRelay.value
        dateFilterComponentView.yearArrowIdxRelay.accept(currentIdx - 1)
        dateFilterComponentView.monthArrowIdxRelay.accept(0)
    }
    
    @objc
    func pressedNextYearBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        print("DiaryBottomSheet :: pressedNextYearBtn!")
        let currentIdx = dateFilterComponentView.yearArrowIdxRelay.value
        dateFilterComponentView.yearArrowIdxRelay.accept(currentIdx + 1)
        dateFilterComponentView.monthArrowIdxRelay.accept(0)
    }
    
    @objc
    func pressedDateFilterBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        print("DiaryBottomSheet :: pressedDateFilterBtn!")
        // let month = dateFilterComponentView.month
        // let filteredDate =
        listener?.filterDatePressedFilterBtn(yearDateFormatString: dateFilterComponentView.yearEngMonth)
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

        show(size: .small,
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
        show(size: .small,
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
    
    func pressedSelectBtn(isEditing: Bool, requestDateComponents: DateComponents, requestDate: Date) {
        switch isEditing {
        case true:
            print("DiaryBottomSheet :: 수정모드 이므로 팝업 띄웁니다")

        case false:
            print("DiaryBottomSheet :: 새로 등록하므로 팝업 안띄웁니다.")
        }
        
        listener?.reminderCompViewshowToast(isEding: isEditing)
        
        let model = ReminderRequsetModel(isEditing: isEditing,
                                         requestDateComponents: requestDateComponents,
                                         requestDate: requestDate
        )
        listener?.reminderRequestDateRelay?.accept(model)
        hideBottomSheetAndGoBack()
    }
    
    func pressedQuestionBtn() {
        print("DiaryBottomSheet :: pressedReminderQuestionBtn")

        show(size: .large,
             buttonType: .oneBtn,
             titleText: MenualString.reminder_alert_title_qna,
             subTitleText: MenualString.reminder_alert_desc_qna,
             confirmButtonText: MenualString.reminder_alert_confirm_qna)
    }
    
    func isNeedReminderAuthorization() {
        show(size: .large,
             buttonType: .oneBtn,
             titleText: "알림 권한이 필요합니다",
             subTitleText: "설정에서 Menual의\n알림을 활성화 해주세요.",
             confirmButtonText: "네"
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
        show(size: .small,
             buttonType: .twoBtn,
             titleText: "리마인더 알림을 해제하시겠어요?",
             cancelButtonText: "아니요",
             confirmButtonText: "네"
        )
    }
}

// MARK: - Dialog
extension DiaryBottomSheetViewController: DialogDelegate {
    func action(titleText: String) {
        print("DiaryBottomSheet :: action! -> \(titleText)")
        switch titleText {
        case "이 메뉴얼을 숨기시겠어요?", "숨긴 메뉴얼을 보시겠어요?":
            print("DiaryBottomSheet :: 숨기기 action!")
            listener?.menuComponentRelay?.accept(.hide)
            hideBottomSheetAndGoBack()
            
        case "해당 메뉴얼을 삭제하시겠어요?":
            listener?.menuComponentRelay?.accept(.delete)
            hideBottomSheetAndGoBack()
            
        case "설정에서 Menual의 알림을 활성화 해주세요.":
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            break
            
        case "리마인더 알림을 해제하시겠어요?":
            listener?.isEnabledReminderRelay?.accept(false)
            break
            
        case "날짜를 선택해 보세요":
            break

        default:
            break
        }
    }
    
    func exit(titleText: String) {
        print("DiaryBottomSheet :: exit!")
        switch titleText {
        case "이 메뉴얼을 숨기시겠어요?", "숨긴 메뉴얼을 보시겠어요?":
            print("DiaryBottomSheet :: 숨기기 exit!")
            hideBottomSheetAndGoBack()
            break
            
        case "해당 메뉴얼을 삭제하시겠어요?":
            hideBottomSheetAndGoBack()
            break
            
        case "설정에서 Menual의 알림을 활성화 해주세요.":
            break
            
        case "리마인더 알림을 해제하시겠어요?":
            break

        default:
            break
        }
    }
}
