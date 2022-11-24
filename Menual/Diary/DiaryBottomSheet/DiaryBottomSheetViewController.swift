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
//    case weather
//    case place
    case menu
    case calender
    case reminder
    case filter
    case dateFilter
}

protocol DiaryBottomSheetPresentableListener: AnyObject {
    var filteredDateDiaryCountRelay: BehaviorRelay<Int>? { get }
    var filteredDateRelay: BehaviorRelay<Date?>? { get }
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>? { get }
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>? { get }
    
    func pressedCloseBtn()
    func pressedWriteBtn()
    
    // MenualBottomSheetMenuComponentView
    var menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>? { get set }
    
    func filterWithWeatherPlacePressedFilterBtn()
    func filterDatePressedFilterBtn()
    
    // MenualBottomSheetReminderComponentView
    func reminderCompViewshowToast(isEding: Bool)
    func reminderCompViewSetReminder(isEditing: Bool, requestDateComponents: DateComponents, requestDate: Date)
    var reminderRequestDateRelay: BehaviorRelay<DateComponents?>? { get }
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
    
    var rightBtn = UIButton().then {
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
    
//    private lazy var weatherPlaceSelectView = WeatherPlaceSelectView(type: .place).then {
//        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.delegate = self
//        $0.isHidden = true
//    }
    
    // 메뉴 컴포넌트
    private lazy var menuComponentView = MenualBottomSheetMenuComponentView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.isHidden = true
        $0.editMenuBtn.addTarget(self, action: #selector(pressedEditBtn), for: .touchUpInside)
        $0.deleteMenuBtn.addTarget(self, action: #selector(pressedDeleteBtn), for: .touchUpInside)
        $0.hideMenuBtn.addTarget(self, action: #selector(pressedHideMenuBtn), for: .touchUpInside)
    }
    
    // 필터 컴포넌트
    private lazy var filterComponentView = MenualBottomSheetFilterComponentView().then {
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
        setViews()
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
        listener?.pressedCloseBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        showBottomSheet()
    }
    
    func setViews() {
        // super.delegate = self
        
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
        
        // 타입별 컴포넌트 SetViews
//        bottomSheetView.addSubview(weatherPlaceSelectView)
        bottomSheetView.addSubview(menuComponentView)
        bottomSheetView.addSubview(filterComponentView)
        bottomSheetView.addSubview(dateFilterComponentView)
        bottomSheetView.addSubview(reminderComponentView)

//        weatherPlaceSelectView.snp.makeConstraints { make in
//            make.leading.width.equalToSuperview()
//            make.height.equalTo(32)
//            make.top.equalTo(self.divider.snp.bottom).offset(16)
//        }

        menuComponentView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(self.divider.snp.bottom).offset(20)
        }
//
        filterComponentView.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalTo(self.divider.snp.bottom).offset(27)
            make.height.equalTo(260)
        }

        dateFilterComponentView.snp.makeConstraints { make in
            make.top.equalTo(self.divider.snp.bottom).offset(64)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(260)
        }
        
        reminderComponentView.snp.makeConstraints { make in
            make.top.equalTo(self.divider.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.width.equalToSuperview().inset(24)
            make.height.equalTo(488)
            // make.bottom.equalToSuperview().inset(35)
        }
    }

    
    @objc
    func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
         hideBottomSheetAndGoBack()
         resignFirstResponder()
    }
    
    func setViews(type: MenualBottomSheetType) {
        print("DiaryBottomSheet :: menualBottomSheetType = \(type)")
        menualBottomSheetType = type
        
        switch menualBottomSheetType {
        case .reminder:
            bottomSheetTitle = "리마인더 알림"
            reminderComponentView.isHidden = false
            menualBottomSheetRightBtnType = .close
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .menu:
            bottomSheetTitle = "메뉴"
            print("DiaryBottomSheet :: 메뉴입니다.")
            menuComponentView.isHidden = false
            menualBottomSheetRightBtnType = .close
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .filter:
            bottomSheetTitle = "필터"
            filterComponentView.isHidden = false
            menualBottomSheetRightBtnType = .close
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .dateFilter:
            bottomSheetTitle = "필터"
            dateFilterComponentView.isHidden = false
            menualBottomSheetRightBtnType = .close
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .calender:
            bottomSheetTitle = "날짜"
            
        
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
    func closeBottomSheet() {
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
            bottomSheetTitle = "날짜"
            bottomSheetHeight = 375
            
        case .filter, .dateFilter:
            bottomSheetTitle = "필터"
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
    func pressedFilterBtn() {
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
    var filteredDateMenaulCountsObservable: Observable<Int>? {
        listener?.filteredDateDiaryCountRelay?.asObservable()
    }
    
    var filteredDateRelay: BehaviorRelay<Date?>? {
        listener?.filteredDateRelay
    }
    
    func setDateFilteredRelay() {
        dateFilterComponentView.bind()
    }
    
    @objc
    func pressedPrevMonthBtn() {
        print("DiaryBottomSheet :: pressedPrevMonthBtn!")
        guard let date = filteredDateRelay?.value else { return }
        let prevMonth = Calendar.current.component(.month, from: date)
        let prevMonthDate = Calendar.current.date(byAdding: .month, value: prevMonth == 1 ? +11 : -1, to: date) ?? Date()
        listener?.filteredDateRelay?.accept(prevMonthDate)
    }
    
    @objc
    func pressedNextMonthBtn() {
        print("DiaryBottomSheet :: pressedNextMonthBtn!")
        guard let date = filteredDateRelay?.value else { return }
        let nextMonth = Calendar.current.component(.month, from: date)
        let nextMonthDate = Calendar.current.date(byAdding: .month, value: nextMonth == 12 ? -11 : +1, to: date) ?? Date()
        listener?.filteredDateRelay?.accept(nextMonthDate)
    }
    
    @objc
    func pressedPrevYearBtn() {
        print("DiaryBottomSheet :: pressedPrevYearBtn!")
        guard let date = filteredDateRelay?.value else { return }
        let prevYearDate = Calendar.current.date(byAdding: .year, value: -1, to: date) ?? Date()
        listener?.filteredDateRelay?.accept(prevYearDate)
    }
    
    @objc
    func pressedNextYearBtn() {
        print("DiaryBottomSheet :: pressedNextYearBtn!")
        guard let date = filteredDateRelay?.value else { return }
        let currentDate = Date()
        let nextYearDate = Calendar.current.date(byAdding: .year, value: +1, to: date) ?? Date()
        if currentDate < nextYearDate {
            print("DiaryBottomSheet :: 미래는 안된단다!")
        }
        listener?.filteredDateRelay?.accept(nextYearDate)
    }
    
    @objc
    func pressedDateFilterBtn() {
        print("DiaryBottomSheet :: pressedDateFilterBtn!")
        listener?.filterDatePressedFilterBtn()
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
    func pressedHideMenuBtn() {
        print("DiaryBottomSheet :: pressedHideMenuBtn")
        show(size: .small,
             buttonType: .twoBtn,
             titleText: "이 메뉴얼을 숨기시겠어요?",
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
    }
    
    @objc
    func pressedEditBtn() {
        print("DiaryBottomSheet :: pressedEditBtn")
        listener?.menuComponentRelay?.accept(.edit)
    }
    
    @objc
    func pressedDeleteBtn() {
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
    var reminderRequestDateRelay: BehaviorRelay<DateComponents?>? {
        listener?.reminderRequestDateRelay
    }
    
    func pressedSelectBtn(isEditing: Bool, requestDateComponents: DateComponents, requestDate: Date) {
//        switch isEditing {
//        case true:
//            showToast(message: "리마인더 알림이 수정되었어요.")
//            hideBottomSheetAndGoBack()
//
//
//        case false:
//            showToast(message: "리마인더 알림이 설정되었어요.")
//            hideBottomSheetAndGoBack()
//        }
//
        
        listener?.reminderCompViewshowToast(isEding: isEditing)
        listener?.reminderCompViewSetReminder(isEditing: isEditing, requestDateComponents: requestDateComponents, requestDate: requestDate)
        hideBottomSheetAndGoBack()
    }
    
    func pressedQuestionBtn() {
        print("DiaryBottomSheet :: pressedReminderQuestionBtn")

        show(size: .large,
             buttonType: .oneBtn,
             titleText: "날짜를 선택해 보세요",
             subTitleText: "오늘 쓴 일기 알림을 보내드려요.\n과거의 내가 어떻게 달라졌는지 확인해 보세요",
             confirmButtonText: "좋아요")
    }
    
    func isNeedReminderAuthorization() {
        show(size: .small,
             buttonType: .oneBtn,
             titleText: "설정에서 Menual의 알림을 활성화 해주세요.",
             confirmButtonText: "네"
        )
    }
    
    func setCurrentReminderData(isEnabled: Bool, dateComponets: DateComponents?) {
        print("DiaryBottomSheet :: setCurrentReminderData! => isEnabled = \(isEnabled), dateComponents = \(dateComponets)")
        reminderComponentView.bindDlelegateRelay()
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
        case "이 메뉴얼을 숨기시겠어요?":
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
            reminderComponentView.isEnabledReminderRelay.accept(false)
            break

        default:
            break
        }
    }
    
    func exit(titleText: String) {
        print("DiaryBottomSheet :: exit!")
        switch titleText {
        case "이 메뉴얼을 숨기시겠어요?":
            print("DiaryBottomSheet :: 숨기기 exit!")
            hideBottomSheetAndGoBack()
            
        case "해당 메뉴얼을 삭제하시겠어요?":
            hideBottomSheetAndGoBack()
            
        case "설정에서 Menual의 알림을 활성화 해주세요.":
            break
            
        case "리마인더 알림을 해제하시겠어요?":
            break

        default:
            break
        }
    }
}
