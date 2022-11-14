//
//  MenualBottomSheetReminderComponentView.swift
//  Menual
//
//  Created by 정진균 on 2022/11/13.
//

import UIKit
import Then
import SnapKit

protocol MenualBottomSheetReminderComponentViewDelegate {
    func pressedQuestionBtn()
}

class MenualBottomSheetReminderComponentView: UIView {
    
    var delegate: MenualBottomSheetReminderComponentViewDelegate?
    
    // 윤달 처리를 위해서
    private var numOfDaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]

    var currentMonthIndex: Int = 0
    var currentYear: Int = 0
    var presentMonthIndex = 0
    var presentYear = 0
    var todaysDate = 0
    var firstWeekDayOfMonth = 0   //(Sunday-Saturday 1-
    
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
    }
    
    private let divider = Divider(type: ._1px).then {
        $0.backgroundColor = Colors.grey.g700
    }
    
    private let monthView = MonthView().then { (view: MonthView) in
        view.yearAndMonth = "2022.12"
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var selectBtn = BoxButton(frame: .zero, btnStatus: .inactive, btnSize: .large).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "선택 완료"
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
    
    // 윤달 처리
    func setLeapYear() {
        if currentMonthIndex == 2 && currentYear % 4 == 0 {
            numOfDaysInMonth[currentMonthIndex-1] = 29
        }
    }
    
    func setInitCalendar() {
        currentMonthIndex = Calendar.current.component(.month, from: Date())
        presentMonthIndex = currentMonthIndex
        currentYear = Calendar.current.component(.year, from: Date())
        presentYear = currentYear
        todaysDate = Calendar.current.component(.day, from: Date())
        firstWeekDayOfMonth=getFirstWeekDay()
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
        // delegate?.pressedQuestionBtn()
        calendarCollectionView.reloadData()
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
        print("Reminder :: !!")
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else {
            return UICollectionViewCell()
        }

        if indexPath.item <= firstWeekDayOfMonth - 2 {
            let calcDate = numOfDaysInMonth[currentMonthIndex - 2] - ((firstWeekDayOfMonth - 2) / (indexPath.row + 1))
            cell.date = "\(calcDate)"
            // cell.isHidden = true
        } else {
            let calcDate = indexPath.row - firstWeekDayOfMonth + 2
            cell.isHidden = false
            cell.date = "\(calcDate)"

            // 현재 표시하고 있는 달이 현재 날짜보다 지난 날일 경우 선택 못하도록
            if calcDate < todaysDate && currentYear == presentYear && currentMonthIndex == presentMonthIndex {
                print("Reminder :: 1- calcDate! \(calcDate)")
                cell.isUserInteractionEnabled = false
                cell.labelColor = Colors.grey.g600
            } else {
                print("Reminder :: 2- calcDate! \(calcDate)")
                cell.isUserInteractionEnabled = true
                cell.labelColor = Colors.grey.g200

                // 다음달 일 경우
                if indexPath.item > numOfDaysInMonth[currentMonthIndex - 1] + firstWeekDayOfMonth - 2 {
                    let calcDate = indexPath.row - (firstWeekDayOfMonth - 2) - numOfDaysInMonth[currentMonthIndex - 1]
                    cell.date = "\(calcDate)"
                    cell.isUserInteractionEnabled = false
                    cell.labelColor = Colors.grey.g600
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
