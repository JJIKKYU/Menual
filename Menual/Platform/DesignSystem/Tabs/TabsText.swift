//
//  TabsText.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import UIKit
import SnapKit
import Then

class TabsText: UIView {
    var number: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    let numberLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppHead(.head_1)
        $0.textColor = Colors.grey.g800
    }
    
    let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppHead(.head_2)
        $0.textColor = Colors.grey.g800
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(numberLabel)
        addSubview(titleLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(numberLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        numberLabel.text = number
        titleLabel.text = title
    }

}
