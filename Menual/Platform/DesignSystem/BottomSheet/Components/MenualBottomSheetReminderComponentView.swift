//
//  MenualBottomSheetReminderComponentView.swift
//  Menual
//
//  Created by 정진균 on 2022/11/13.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxRelay
import RxViewController
import FirebaseAnalytics

protocol MenualBottomSheetReminderComponentViewDelegate: AnyObject {
    var reminderRequestDateRelay: BehaviorRelay<ReminderRequsetModel?>? { get }
    func pressedQuestionBtn()
    func pressedIsEnabledSwitchBtn(isEnabled: Bool)
    func pressedSelectBtn(isEditing: Bool, requestDateComponents: DateComponents, requestDate: Date)
    func isNeedReminderAuthorization()
    var isEnabledReminderRelay: BehaviorRelay<Bool?>? { get }
}

class MenualBottomSheetReminderComponentView: UIView {
    
    weak var delegate: MenualBottomSheetReminderComponentViewDelegate?
    
    // 윤달 처리를 위해서
    private var numOfDaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]

    // 오늘 연도 / 달
    var currentMonthIndex: Int = 0
    var currentYear: Int = 0

    // 오늘이 아닌 보여주고 있는 연도 / 달
    var presentMonthIndex = 0
    var presentYear = 0

    var todaysDate = 0
    var firstWeekDayOfMonth = 0   //(Sunday-Saturday 1-
    
    // private var isInitSetting: Bool = false
    var pressedSelctBtn: Bool = false
    
    var isEditingMode: Bool = false
    
    public var dateComponets: DateComponents? {
        didSet { setNeedsLayout() }
    }
    
    private let isNeedReminderAuthorizationRelay = BehaviorRelay<Bool>(value: false)
    private let isSelectedReminderDayIndexRelay = BehaviorRelay<Int?>(value: nil)

    private let disposedBag = DisposeBag()
    
    private let reminderTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g200
        $0.font = UIFont.AppBodyOnlyFont(.body_3)
        $0.text = "선택한 날짜에 알람 받기"
    }
    
    private lazy var reminderTitleQuestionBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.question.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g500
        $0.addTarget(self, action: #selector(pressedQuestionBtn), for: .touchUpInside)
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    lazy var switchBtn = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        // $0.addTarget(self, action: #selector(selectedSwitchBtn), for: .touchUpInside)
        $0.onTintColor = Colors.tint.main.v400
        $0.tintColor = Colors.grey.g700
        $0.transform = CGAffineTransform(scaleX: 0.78, y: 0.78)
        $0.isUserInteractionEnabled = false
    }
    
    lazy var switchBtnImp = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(selectedSwitchBtn), for: .touchUpInside)
    }
    
    private let divider = Divider(type: ._1px).then {
        $0.backgroundColor = Colors.grey.g700
    }
    
    private lazy var monthView = MonthView().then { (view: MonthView) in
        view.yearAndMonth = "2022.12"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
    }
    
    private lazy var calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
//        $0.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
//        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.delegate = self
//        $0.dataSource = self
        
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        
        $0.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        
        let flowlayout = UICollectionViewFlowLayout()
        $0.setCollectionViewLayout(flowlayout, animated: true)

    }
    
    private lazy var selectBtn = BoxButton(frame: .zero, btnStatus: .inactive, btnSize: .large).then { (btn: BoxButton) in
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.title = "선택 완료"
        btn.addTarget(self, action: #selector(pressedSelectBtn), for: .touchUpInside)
    }

    init() {
        super.init(frame: CGRect.zero)
        setInitCalendar()
        setLeapYear()
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        print("Reminder :: willMove! = \(delegate)")
        bind()
    }
    
    func setViews() {
        addSubview(reminderTitleLabel)
        addSubview(reminderTitleQuestionBtn)
        addSubview(switchBtn)
        addSubview(switchBtnImp)
        addSubview(divider)
        
        addSubview(monthView)
        addSubview(calendarCollectionView)
        
        addSubview(selectBtn)

        reminderTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(18)
        }
        
        reminderTitleQuestionBtn.snp.makeConstraints { make in
            make.leading.equalTo(reminderTitleLabel.snp.trailing).offset(2)
            make.centerY.equalTo(reminderTitleLabel)
            make.width.height.equalTo(16)
        }

        switchBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(reminderTitleLabel)
        }
        
        switchBtnImp.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(switchBtn)
            make.width.height.equalTo(switchBtn)
        }

        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(reminderTitleLabel.snp.bottom).offset(19)
            make.width.equalToSuperview()
            make.height.equalTo(1)
        }
        
        monthView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(24)
            make.top.equalTo(divider.snp.bottom).offset(32)
        }

        calendarCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(monthView.snp.bottom).offset(16)
            make.height.equalTo(300)
        }

        selectBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(48)
            make.top.equalTo(calendarCollectionView.snp.bottom).offset(18)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let dateComponets = dateComponets {
            let weekday = dateComponets.weekday
            let month = dateComponets.month
            let day = dateComponets.day
            
            delegate?.isEnabledReminderRelay?.accept(true)
            print("Reminder :: compView에서 받은 데이터 = weekDay = \(weekday), month = \(month), day = \(day)")
        }
    }
    
    func bind() {
        delegate?.isEnabledReminderRelay?
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self,
                      let isEnabled = isEnabled
                else { return }

                self.monthView.isEnabled = isEnabled
                switch isEnabled {
                case true:
                    self.selectBtn.isEnabled = true
                    self.switchBtn.setOn(true, animated: true)

                case false:
                    self.selectBtn.btnStatus = .inactive
                    self.selectBtn.isEnabled = false
                    self.switchBtn.setOn(false, animated: true)
                    self.isSelectedReminderDayIndexRelay.accept(nil)
                }
                
                self.calendarCollectionView.reloadData()
                
            })
            .disposed(by: disposedBag)
        
        isSelectedReminderDayIndexRelay
            .subscribe(onNext: { [weak self] selectedDate in
                guard let self = self else { return }

                // select가 취소 되었을 경우
                guard let selectedDate = selectedDate else {
                    print("Reminder :: 선택한 날이 없습니다.")
                    self.selectBtn.btnStatus = .inactive
                    self.selectBtn.isUserInteractionEnabled = false
                    return
                }
                
                if selectedDate == self.delegate?.reminderRequestDateRelay?.value?.requestDateComponents?.day ?? 0 {
                    print("Reminder :: 이미 선택했던 날짜와 같을 경우")
                    self.selectBtn.btnStatus = .inactive
                    self.selectBtn.isUserInteractionEnabled = false
                    return
                }
                
                self.selectBtn.btnStatus = .active
                self.selectBtn.isUserInteractionEnabled = true
                print("Reminder :: selectedDate = \(selectedDate)")
                
                print("Reminder :: \(self.currentYear)년 \(self.currentMonthIndex)월 \(selectedDate)일을 선택 하셨습니다.")

            })
            .disposed(by: disposedBag)
        
        delegate?.reminderRequestDateRelay?
            .subscribe(onNext: { [weak self] model in
                guard let self = self,
                      let model = model
                else {
                    self?.isEditingMode = false
                    return
                }
                if self.pressedSelctBtn == true { return }
                print("Reminder :: requestDate = \(model.requestDate)")
                
                guard let requestDate = model.requestDateComponents else {
                    print("Reminder :: requestDate가 없으므로 return 합니다.")
                    self.isEditingMode = false
                    return
                }
                
                print("Reminder :: \(requestDate.year)년 \(requestDate.month)월 \(requestDate.day)일을 세팅해야 합니다.")
                self.isEditingMode = true

                // self.switchBtn.setOn(true, animated: true)
                // self.selectedSwitchBtn()
                // self.isSelectedReminderDayIndexRelay.accept(requestDate.day)

                 // self.selectBtn.btnStatus = .active
                // self.calendarCollectionView.reloadData()
                 // self.selectBtn.isUserInteractionEnabled = true
            })
            .disposed(by: disposedBag)
        
        
        guard let reminderRequestDateRelay = delegate?.reminderRequestDateRelay else { return }
        Observable.combineLatest(
            reminderRequestDateRelay,
            calendarCollectionView.rx.observe(CGSize.self, "contentSize")
        )
        // calendarCollectionView.rx.observe(CGSize.self, "contentSize")
            .subscribe(onNext: { [weak self] (data: (ReminderRequsetModel?, CGSize?)) in
                // if size?.height ?? 0 < 290 { return }
                guard let self = self,
                      let model = data.0,
                      let requestDate = model.requestDateComponents
                else { return }
                if self.pressedSelctBtn == true { return }
                // if self.isInitSetting == true { return }
                
                print("Reminder :: requestDate = \(requestDate), currentYear = \(self.currentYear), currentMonth = \(self.currentMonthIndex)")
                
                if self.currentYear != requestDate.year ?? 0 || self.currentMonthIndex != requestDate.month ?? 0 {
                    print("Reminder :: 다른 곳은 세팅 안해요!")
                    return
                }

                guard let selectedDate = requestDate.day else { return }
                let calcDate = (selectedDate - 1) + (self.firstWeekDayOfMonth - 1)

                // print("Reminder :: Size! = \(size)")
                self.calendarCollectionView.selectItem(at: IndexPath(row: calcDate, section: 0), animated: false, scrollPosition: .top)
                self.collectionView(self.calendarCollectionView, didSelectItemAt: IndexPath(row: calcDate, section: 0))
                
                // self.isInitSetting = true
            })
            .disposed(by: disposedBag)
    }
    
    // 윤달 처리
    func setLeapYear() {
        if currentMonthIndex == 2 && currentYear % 4 == 0 {
            numOfDaysInMonth[currentMonthIndex-1] = 29
        }
    }
    
    func setInitCalendar() {
        monthView.yearAndMonth = Date().toString()
        
        currentMonthIndex = Calendar.current.component(.month, from: Date())
        presentMonthIndex = currentMonthIndex

        currentYear = Calendar.current.component(.year, from: Date())
        presentYear = currentYear

        todaysDate = Calendar.current.component(.day, from: Date())
        firstWeekDayOfMonth = getFirstWeekDay()
    }
    
    func getFirstWeekDay() -> Int {
        let day = ("\(currentYear)-\(currentMonthIndex)-01".date?.fistDayOfTheMonth.weekday)!
       //return day == 7 ? 1 : day
       return day
   }
}

// MARK: - IBAction
extension MenualBottomSheetReminderComponentView {
    @objc
    func pressedQuestionBtn() {
        Analytics.logEvent("BottomSheet_Reminder_Button_QNA", parameters: nil)
        delegate?.pressedQuestionBtn()
        // calendarCollectionView.reloadData()
    }
    
    @objc
    func selectedSwitchBtn() {
        print("Reminder :: isOn = \(switchBtn.isOn)")
        Analytics.logEvent("BottomSheet_Reminder_Button", parameters: ["isOn":"\(switchBtn.isOn)"])

        // 연결되어 있을 경우 연결 해제 팝업
        if switchBtn.isOn == true {
            delegate?.pressedIsEnabledSwitchBtn(isEnabled: false)
            return
        }
        
        // 권한 물어보기
        let userNotiCenter = UNUserNotificationCenter.current()
        let notiAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        userNotiCenter.requestAuthorization(options: notiAuthOptions) { (success, error) in
            if let error = error {
                print(#function, error)
                print("Reminder :: 권한 요청? error! = \(error)")
                self.delegate?.isNeedReminderAuthorization()
            }
            
            if success == true {
                print("Reminder :: 권한 요청? success! = \(success)")
                DispatchQueue.main.async {
                    self.delegate?.isEnabledReminderRelay?.accept(true)
                }
            } else {
                DispatchQueue.main.async {
                    self.switchBtn.setOn(false, animated: true)
                    self.delegate?.isNeedReminderAuthorization()
                }
            }
        }

        
        // 날짜를 선택했다면 팝업 띄우기
//        if isSelectedReminderDayIndexRelay.value != nil {
//
//            return
//        }
        // print("Reminder :: isEnabled = \(isEnabled)")
    }
    
    @objc
    func pressedSelectBtn() {
        guard let selectedDate = isSelectedReminderDayIndexRelay.value else { return }
        
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = currentMonthIndex
        dateComponents.day = selectedDate
        dateComponents.hour = 12
        dateComponents.minute = 00
        dateComponents.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        
        guard let requestDate = Calendar.current.date(from: dateComponents) else { return }
        print("Reminder :: pressedSelectBtn-> \(self.currentYear)년 \(self.currentMonthIndex)월 \(isSelectedReminderDayIndexRelay.value)일을 선택 하셨습니다.")
        print("Reminder :: requestDate = \(requestDate)")
        
        pressedSelctBtn = true
        delegate?.pressedSelectBtn(isEditing: isEditingMode,
                                   requestDateComponents: dateComponents,
                                   requestDate: requestDate
        )
        Analytics.logEvent("BottomSheet_Reminder_Button_Confirm",
                           parameters: [
                            "year": "\(self.currentYear)",
                            "month": "\(self.currentMonthIndex)",
                            "day": "\(isSelectedReminderDayIndexRelay.value ?? 0)"
                                       ]
        )
    }
}

// MARK: - Calendar UICollectionVIew Delegate
extension MenualBottomSheetReminderComponentView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Reminder :: firstWeekDayOfMonth = \(firstWeekDayOfMonth)")
        // return numOfDaysInMonth[currentMonthIndex - 1] + firstWeekDayOfMonth - 1
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else {
            return UICollectionViewCell()
        }

        cell.isToday = false

        if indexPath.item <= firstWeekDayOfMonth - 2 {
            // 저번달이 작년 12월일 경우
            if currentMonthIndex - 2 < 0 {
                let calcDate = numOfDaysInMonth[11] - ((firstWeekDayOfMonth - 2) / (indexPath.row + 1))
                cell.date = "\(calcDate)"
                cell.isUserInteractionEnabled = false
            } else {
                let calcDate = numOfDaysInMonth[currentMonthIndex - 2] - ((firstWeekDayOfMonth - 2) / (indexPath.row + 1))
                cell.date = "\(calcDate)"
                cell.isUserInteractionEnabled = false
            }
            
            // cell.isHidden = true
        } else {
            let calcDate = indexPath.row - firstWeekDayOfMonth + 2
            cell.isHidden = false
            cell.date = "\(calcDate)"

            // 오늘
            if calcDate == todaysDate && currentYear == presentYear && currentMonthIndex == presentMonthIndex {
                cell.isUserInteractionEnabled = false
                // cell.labelColor = Colors.grey.g600
                cell.isToday = true
            }
            // 현재 표시하고 있는 달이 현재 날짜보다 지난 날일 경우 선택 못하도록
            else if calcDate < todaysDate && currentYear == presentYear && currentMonthIndex == presentMonthIndex {
                // print("Reminder :: 1- calcDate! \(calcDate)")
                cell.isUserInteractionEnabled = false
                // cell.labelColor = Colors.grey.g600
            } else {
                // print("Reminder :: 2- calcDate! \(calcDate)")
                cell.isUserInteractionEnabled = true
                // cell.labelColor = Colors.grey.g200

                // 다음달 일 경우
                if indexPath.item > numOfDaysInMonth[currentMonthIndex - 1] + firstWeekDayOfMonth - 2 {
                    let calcDate = indexPath.row - (firstWeekDayOfMonth - 2) - numOfDaysInMonth[currentMonthIndex - 1]
                    cell.date = "\(calcDate)"
                    cell.isUserInteractionEnabled = false
                    cell.labelColor = Colors.grey.g600
                }
            }
        }
        
        cell.index = indexPath.row
        // cell.layoutIfNeeded()
        
        if delegate?.isEnabledReminderRelay?.value ?? false == false {
            cell.isUserInteractionEnabled = false
        }
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {

        guard let cell = collectionView.cellForItem(at: indexPath) as? DateCell else { return true }
        
        // 이미 선택했을 경우 선택해제 되도록
        if cell.isSelected {
            collectionView.deselectItem(at: indexPath, animated: true)
            self.isSelectedReminderDayIndexRelay.accept(nil)
            return false
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? DateCell else { return }
        
        let selectedIndex = cell.index
        let date = cell.date

        print("Reminder :: Selected! cell = \(cell.index), date = \(cell.date)")
        isSelectedReminderDayIndexRelay.accept(Int(cell.date))
        Analytics.logEvent("BottomSheet_Reminder_Button_Date ", parameters: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // print("Reminder :: deS")
        guard let cell = collectionView.cellForItem(at: indexPath) as? DateCell else { return }
        
        print("Reminder :: didDeselected!")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthHeight = collectionView.frame.width / 7
        return CGSize(width: widthHeight, height: widthHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - MonthView Delgate
extension MenualBottomSheetReminderComponentView: MonthViewDelegate {
    func pressedLeftBtn() {
        print("Reminder :: left!")
        Analytics.logEvent("BottomSheet_Reminder_Button_prevYear", parameters: nil)
        if presentYear == currentYear {
            if presentMonthIndex == currentMonthIndex {
                print("Reminder :: 이전 달 이동 불가능")
            } else {
                currentMonthIndex -= 1
            }
        } else if presentYear != currentYear {
            if currentMonthIndex <= 1 {
                currentMonthIndex = 12
                currentYear -= 1
            } else {
                currentMonthIndex -= 1
            }
        }
        
        firstWeekDayOfMonth = getFirstWeekDay()
        monthView.yearAndMonth = "\(currentYear).\(currentMonthIndex)"
        calendarCollectionView.reloadData()
    }
    
    func pressedRightBtn() {
        print("Reminder :: right!")
        Analytics.logEvent("BottomSheet_Reminder_Button_nextYear", parameters: nil)
        // 다음 달 이동이 가능하면
//        if let presentMonth = numOfDaysInMonth[safe: presentMonthIndex] {
//            print("Reminder :: presentMonth = \(presentMonth)")
//            presentMonthIndex += 1
//        }
//
        if currentMonthIndex >= 12  {
            print("Reminder :: 다음 달 이동 불가능")
            currentMonthIndex = 1
            currentYear += 1
        } else {
            print("Reminder :: 다음 달 이동 가능")
            currentMonthIndex += 1
        }
        
        firstWeekDayOfMonth = getFirstWeekDay()
        monthView.yearAndMonth = "\(currentYear).\(currentMonthIndex)"
        calendarCollectionView.reloadData()

        print("Reminder :: currentMonthIndex = \(currentMonthIndex)")
    }
}
