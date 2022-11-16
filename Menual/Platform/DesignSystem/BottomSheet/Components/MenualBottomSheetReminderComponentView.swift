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

protocol MenualBottomSheetReminderComponentViewDelegate {
    func pressedQuestionBtn()
    func pressedSelectBtn(isEditing: Bool)
}

class MenualBottomSheetReminderComponentView: UIView {
    
    var delegate: MenualBottomSheetReminderComponentViewDelegate?
    
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
    
    private let isEnabledReminderRelay = BehaviorRelay<Bool>(value: false)
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
        $0.addTarget(self, action: #selector(selectedSwitchBtn), for: .touchUpInside)
        $0.onTintColor = Colors.tint.main.v400
        $0.tintColor = Colors.grey.g700
        $0.transform = CGAffineTransform(scaleX: 0.78, y: 0.78)
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
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(reminderTitleLabel)
        addSubview(reminderTitleQuestionBtn)
        addSubview(switchBtn)
        addSubview(divider)
        
        addSubview(monthView)
        addSubview(calendarCollectionView)
        
        addSubview(selectBtn)

        reminderTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(16)
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
    }
    
    func bind() {
        isEnabledReminderRelay
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self else { return }

                self.monthView.isEnabled = isEnabled
                switch isEnabled {
                case true:
                    self.selectBtn.isEnabled = true

                case false:
                    self.selectBtn.btnStatus = .inactive
                    self.selectBtn.isEnabled = false
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
                
                self.selectBtn.btnStatus = .active
                self.selectBtn.isUserInteractionEnabled = true
                print("Reminder :: selectedDate = \(selectedDate)")
                
                print("Reminder :: \(self.currentYear)년 \(self.currentMonthIndex)월 \(selectedDate)일을 선택 하셨습니다.")

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
        delegate?.pressedQuestionBtn()
        // calendarCollectionView.reloadData()
    }
    
    @objc
    func selectedSwitchBtn() {
        let isEnabled = switchBtn.isOn
        print("Reminder :: isEnabled = \(isEnabled)")
        
        // 날짜를 선택했다면 팝업 띄우기
//        if isSelectedReminderDayIndexRelay.value != nil {
//
//            return
//        }
        isEnabledReminderRelay.accept(isEnabled)
    }
    
    @objc
    func pressedSelectBtn() {
        print("Reminder :: pressedSelectBtn!")
        delegate?.pressedSelectBtn(isEditing: false)
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
        
        if isEnabledReminderRelay.value == false {
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

        /*
         
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                print("Reminder :: 알림 권한이 없습니다.")
                return
            }
            
            if settings.alertSetting == .enabled {
                // Schedule an alert-only notification
                print("Reminder :: 알림 권한이 enabled 합니다. - Schedule an alert-only notification")
            } else {
                print("Reminder :: 알림 권한이 enabled 합니다. - Schedule a notification with a badge and sound.")
            }
            
            let content = UNMutableNotificationContent()
            content.title = "알림 테스트입니다."
            content.body = "알림 테스트 알림 테스트 알림 테스트 알림 테스트 알림 테스트"
            
            // Configure the recurring date.
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.weekday = 2
            dateComponents.hour = 17
            dateComponents.minute = 41
            
            // Create the trigger as a repating event.
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // Create the request
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            // Schedule the request with the system
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { error in
                print("Reminder :: 됐나!? - 1")
                if error != nil {
                    print("Reminder :: 됐나!? NoError! - 2")
                }
            }
        }
         */
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
