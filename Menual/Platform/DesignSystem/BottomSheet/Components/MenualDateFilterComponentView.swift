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
    var filteredMenaulCountsObservable: Observable<Int> { get }
    var filteredDateRelay: BehaviorRelay<Date>? { get }
}

class MenualDateFilterComponentView: UIView {
    
    public var delegate: MenualDateFilterComponentDelegate?
    var disposeBag = DisposeBag()
   
    // Year
    public lazy var prevYearArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g700
        $0.isUserInteractionEnabled = true
    }
    
    public lazy var nextYearArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.front.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g700
        $0.isUserInteractionEnabled = true
    }
    
    private let yearTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_5)
        $0.textColor = Colors.grey.g100
        $0.text = "2022년"
    }
    
    // Month
    public lazy var prevMonthArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g700
        $0.isUserInteractionEnabled = true
    }
    
    public lazy var nextMonthArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.front.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g700
        $0.isUserInteractionEnabled = true
    }
    
    private let monthTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_5)
        $0.textColor = Colors.grey.g100
        $0.text = "12월"
    }
    
    public let filterBtn = BoxButton(frame: .zero, btnStatus: .inactive, btnSize: .large).then {
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
                
                print("DiaryBottomSheet :: filteredDateRelay 넘어왔당아! \(date)")
            })
            .disposed(by: disposeBag)
        
        delegate?.filteredMenaulCountsObservable
            .subscribe(onNext: { [weak self] count in
                guard let self = self else { return }
                
                print("DiaryBottomSheet :: filteredMenualCountsObservable 구독! = \(count)")
            })
            .disposed(by: disposeBag)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
