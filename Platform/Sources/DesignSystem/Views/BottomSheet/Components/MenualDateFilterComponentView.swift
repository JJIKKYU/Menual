//
//  MenualDateFilterComponentView.swift
//  Menual
//
//  Created by 정진균 on 2022/09/10.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxRelay
import MenualEntity

public protocol MenualDateFilterComponentDelegate: AnyObject {
    var dateFilterModelRelay: BehaviorRelay<[DateFilterModel]?>? { get }
}

public class MenualDateFilterComponentView: UIView {
    
    public weak var delegate: MenualDateFilterComponentDelegate?

    var disposeBag = DisposeBag()

    let currentYear = Calendar.current.component(.year, from: Date())
    let currentMonth = Calendar.current.component(.month, from: Date())
    
    public let monthArrowIdxRelay = BehaviorRelay<Int>(value: 0)
    public let yearArrowIdxRelay = BehaviorRelay<Int>(value: 0)
    
    // "2022NOV" 같은 DiaryHome에서 사용
    public var yearEngMonth: String = ""
    
    private var month: String = "00" {
        didSet { setNeedsLayout() }
    }
    
    private var year: String = "0000" {
        didSet { setNeedsLayout() }
    }
    
    private var count: Int = 0 {
        didSet { setNeedsLayout() }
    }
   
    // Year
    public lazy var prevYearArrowBtn = UIButton().then {
        $0.actionName = "prevYear"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g200
        $0.isUserInteractionEnabled = true
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    public lazy var nextYearArrowBtn = UIButton().then {
        $0.actionName = "nextYear"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.front.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g700
        $0.isUserInteractionEnabled = true
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    private let yearTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_5)
        $0.textColor = Colors.grey.g100
        $0.text = "2022년"
    }
    
    // Month
    public lazy var prevMonthArrowBtn = UIButton().then {
        $0.actionName = "prevMonth"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g200
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    public lazy var nextMonthArrowBtn = UIButton().then {
        $0.actionName = "nextMonth"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.front.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g700
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }

    private let monthTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_5)
        $0.textColor = Colors.grey.g100
        $0.text = "12월"
    }
    
    public let filterBtn = BoxButton(frame: .zero, btnStatus: .active, btnSize: .large).then {
        $0.actionName = "confirm"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트"
    }

    public init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(prevYearArrowBtn)
        addSubview(nextYearArrowBtn)
        addSubview(yearTitle)
        
        prevYearArrowBtn.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        nextYearArrowBtn.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        yearTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(prevYearArrowBtn)
        }
        
        addSubview(prevMonthArrowBtn)
        addSubview(nextMonthArrowBtn)
        addSubview(monthTitle)
        
        prevMonthArrowBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(prevYearArrowBtn.snp.bottom).offset(41)
            make.width.height.equalTo(24)
        }
        
        nextMonthArrowBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(prevMonthArrowBtn)
            make.width.height.equalTo(24)
        }
        
        monthTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(prevMonthArrowBtn)
        }
        
        addSubview(filterBtn)
        
        filterBtn.snp.makeConstraints { make in
            make.top.equalTo(prevMonthArrowBtn.snp.bottom).offset(79)
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(48)
        }
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        print("DiaryBottomSheet :: willMove!")
        bind()
    }
    
    func bind() {
        delegate?.dateFilterModelRelay?
            .subscribe(onNext: { [weak self] dateFilterModelArr in
                guard let self = self else { return }
                
                guard let dateFilterModelArr = dateFilterModelArr else {
                    print("DiaryBottomSheet :: dateFilterModelArr가 nil이므로 선택할 곳이 없게 합니다.")
                    return
                }
                
                let calendar = Calendar.current

                // 이번년도 찾기
                // 이번달 찾기
                var yearIndex: Int = 0
                var monthIndex: Int = 0
                for (index, model) in dateFilterModelArr.enumerated() {
                    if model.year == self.currentYear {
                        yearIndex = index

                        for (index, modelMonthModel) in model.months.enumerated() {
                            if self.currentMonth == modelMonthModel.month {
                                monthIndex = index
                            }
                        }
                    }
                }
                
                
                print("DiaryBottomSheet :: 이번년도Idx = \(yearIndex), 이번달Idx = \(monthIndex)")
                print("DiaryBottomSheet :: \(dateFilterModelArr[safe: yearIndex]?.months[safe: monthIndex]?.month)월, \(dateFilterModelArr[safe: yearIndex]?.months[safe: monthIndex]?.diaryCount)개")
                
                // print("DiaryBottomSheet :: dateFilterModelRelay = \(model)")
                self.yearArrowIdxRelay.accept(yearIndex)
                self.monthArrowIdxRelay.accept(monthIndex)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            yearArrowIdxRelay,
            monthArrowIdxRelay
        )
        .subscribe(onNext: { [weak self] yearIdx, monthIdx in
            guard let self = self else { return }
            guard let dateFilterModelArr = self.delegate?.dateFilterModelRelay?.value else { return }
            
            print("DiaryBottomSheet :: yearIdx = \(yearIdx), monthIdx = \(monthIdx)")
            print("DiaryBottomSheet :: dateFilterModelArr[safe: yearIdx + 1] = \(dateFilterModelArr[safe: yearIdx + 1])")
            
            
            if dateFilterModelArr[safe: yearIdx - 1] == nil {
                print("DiaryBottomSheet :: prevYear은 nil이므로 비활성화")
                self.prevYearArrowBtn.tintColor = Colors.grey.g700
                self.prevYearArrowBtn.isUserInteractionEnabled = false
            } else {
                // self.monthArrowIdxRelay.accept(0)
                self.prevYearArrowBtn.tintColor = Colors.grey.g200
                self.prevYearArrowBtn.isUserInteractionEnabled = true
            }
            
            if dateFilterModelArr[safe: yearIdx + 1] == nil {
                print("DiaryBottomSheet :: nextYear은 nil이므로 비활성화")
                self.nextYearArrowBtn.tintColor = Colors.grey.g700
                self.nextYearArrowBtn.isUserInteractionEnabled = false
            } else {
                // self.monthArrowIdxRelay.accept(0)
                self.nextYearArrowBtn.tintColor = Colors.grey.g200
                self.nextYearArrowBtn.isUserInteractionEnabled = true
            }
            
            if dateFilterModelArr[safe: yearIdx]?.months[safe: monthIdx - 1] == nil {
                print("DiaryBottomSheet :: prevMonth nil이므로 비활성화")
                self.prevMonthArrowBtn.tintColor = Colors.grey.g700
                self.prevMonthArrowBtn.isUserInteractionEnabled = false
            } else {
                self.prevMonthArrowBtn.tintColor = Colors.grey.g200
                self.prevMonthArrowBtn.isUserInteractionEnabled = true
            }
            
            if dateFilterModelArr[safe: yearIdx]?.months[safe: monthIdx + 1] == nil {
                print("DiaryBottomSheet :: nextMonth nil이므로 비활성화")
                self.nextMonthArrowBtn.tintColor = Colors.grey.g700
                self.nextMonthArrowBtn.isUserInteractionEnabled = false
            } else {
                self.nextMonthArrowBtn.tintColor = Colors.grey.g200
                self.nextMonthArrowBtn.isUserInteractionEnabled = true
            }
            
            self.year = String(dateFilterModelArr[safe: yearIdx]?.year ?? self.currentYear)
            
            self.month = String(dateFilterModelArr[safe: yearIdx]?.months[safe: monthIdx]?.month ?? self.currentMonth)
            if self.month.count == 1 {
                self.month = "0" + self.month
            }
            // let engMonth = String(self.month).convertEngMonthName()
            // self.yearEngMonth = self.year + engMonth
            self.yearEngMonth = self.year + "." + self.month
            print("DiaryBottomSheet :: EngMonthFormat = \(self.yearEngMonth)")
            self.count = dateFilterModelArr[safe: yearIdx]?.months[safe: monthIdx]?.diaryCount ?? 0
        })
        .disposed(by: disposeBag)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        monthTitle.text = "\(month)월"
        yearTitle.text = "\(year)년"
        filterBtn.title = "\(count)개의 메뉴얼 보기"
        
        // count가 0이 잡힌다는 것은 하나도 안쓴 상태
        if count == 0 {
            monthTitle.text = "-"
            yearTitle.text = "-"
            filterBtn.title = "작성한 메뉴얼이 없어요."
            filterBtn.btnStatus = .inactive
            filterBtn.isUserInteractionEnabled = false
        } else {
            filterBtn.btnStatus = .active
            filterBtn.isUserInteractionEnabled = true
        }
        
        
        
        /*
        print("DiaryBottomSheet = \(currentYear) \(Int(year) ?? 0 + 1) ,,,, \(currentMonth < Int(month) ?? 0)")
        if currentYear == (Int(year) ?? 0) + 1 && currentMonth < Int(month) ?? 0 {
            print("DiaryBottomSheet :: 내년을 누르면 미래가 되어버리니 비활성화합니다.")
            nextYearArrowBtn.tintColor = Colors.grey.g700
            nextYearArrowBtn.isUserInteractionEnabled = false
        }
        
        // 오늘 연도 / 월이 같으면 미래 일기는 볼 수 없도록 비활성화
        else if String(currentYear) == year && String(currentMonth) == month {
            nextMonthArrowBtn.tintColor = Colors.grey.g700
            nextMonthArrowBtn.isUserInteractionEnabled = false
            
            nextYearArrowBtn.tintColor = Colors.grey.g700
            nextYearArrowBtn.isUserInteractionEnabled = false
        } else if String(currentYear) == year {
            nextYearArrowBtn.tintColor = Colors.grey.g700
            nextYearArrowBtn.isUserInteractionEnabled = false
            
            nextMonthArrowBtn.tintColor = Colors.grey.g200
            nextMonthArrowBtn.isUserInteractionEnabled = true
        } else {
            nextMonthArrowBtn.tintColor = Colors.grey.g200
            nextMonthArrowBtn.isUserInteractionEnabled = true
            
            nextYearArrowBtn.tintColor = Colors.grey.g200
            nextYearArrowBtn.isUserInteractionEnabled = true
        }
        */
    }
}