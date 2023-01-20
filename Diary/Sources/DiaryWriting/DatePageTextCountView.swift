//
//  DatePageTextCountView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import UIKit
import SnapKit
import Then
import DesignSystem
import MenualUtil

class DatePageTextCountView: UIView {
    
    var date: String = "2022.99.99" {
        didSet { setNeedsLayout() }
    }
    
    var page: String = "999" {
        didSet { setNeedsLayout() }
    }
    
    var textCount: String = "0" {
        didSet { setNeedsLayout() }
    }
    
    private let dateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g600
    }
    
    private let divider = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g600
    }
    
    private let pageLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g600
    }
    
    private let textCountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g600
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(dateLabel)
        addSubview(divider)
        addSubview(pageLabel)
        addSubview(textCountLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(9)
            make.height.equalTo(1)
            make.centerY.equalToSuperview()
        }
        
        pageLabel.snp.makeConstraints { make in
            make.leading.equalTo(divider.snp.trailing).offset(8)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        textCountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dateLabel.text = date
        pageLabel.text = "P.\(page)"
        textCountLabel.text = String(format: MenualString.writing_desc_menual_desc_with_count, Int(textCount) ?? 0)
    }

}
