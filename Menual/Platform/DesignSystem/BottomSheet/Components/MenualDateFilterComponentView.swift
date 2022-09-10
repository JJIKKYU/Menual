//
//  MenualDateFilterComponentView.swift
//  Menual
//
//  Created by 정진균 on 2022/09/10.
//

import UIKit
import SnapKit
import Then

class MenualDateFilterComponentView: UIView {
   
    // Year
    private let prevYearArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g700
    }
    
    private let nextYearArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.front.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g700
    }
    
    private let yearTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_5)
        $0.textColor = Colors.grey.g100
        $0.text = "2022년"
    }
    
    // Month
    private let prevMonthArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g700
    }
    
    private let nextMonthArrowBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.front.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g700
    }
    
    private let monthTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_5)
        $0.textColor = Colors.grey.g100
        $0.text = "12월"
    }
    
    private let filterBtn = BoxButton(frame: .zero, btnStatus: .inactive, btnSize: .large).then {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
