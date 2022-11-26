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

protocol MenualDateFilterComponentDelegate {
    var filteredDateMenaulCountsObservable: Observable<Int>? { get }
    var filteredDateRelay: BehaviorRelay<Date?>? { get }
}

class MenualDateFilterComponentView: UIView {
    
    public var delegate: MenualDateFilterComponentDelegate?

    var disposeBag = DisposeBag()

    let currentYear = Calendar.current.component(.year, from: Date())
    let currentMonth = Calendar.current.component(.month, from: Date())
    
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
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g200
        $0.isUserInteractionEnabled = true
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    public lazy var nextYearArrowBtn = UIButton().then {
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
    lazy var prevMonthArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g200
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    public lazy var nextMonthArrowBtn = UIButton().then {
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
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "텍스트"
    }

    init() {
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
    
    func bind() {
        print("DiaryBottomSheet :: filterDate 바인드!")
        delegate?.filteredDateRelay?
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                guard let date = date else { return }
                
                print("DiaryBottomSheet :: filteredDateRelay 넘어왔당아! \(date)")
                
                let calendar = Calendar.current
                let month = calendar.component(.month, from: date)
                self.month = String(month)
                
                let year = calendar.component(.year, from: date)
                self.year = String(year)
            })
            .disposed(by: disposeBag)

        delegate?.filteredDateMenaulCountsObservable?
            .subscribe(onNext: { [weak self] count in
                guard let self = self else { return }
                
                print("DiaryBottomSheet :: filteredMenualCountsObservable 구독! = \(count)")
                self.count = count
            })
            .disposed(by: disposeBag)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        monthTitle.text = "\(month)월"
        yearTitle.text = "\(year)년"
        filterBtn.title = "\(count)개의 메뉴얼 보기"
        
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
    }
}
