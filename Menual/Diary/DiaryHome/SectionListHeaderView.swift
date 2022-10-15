//
//  SectionListHeaderView.swift
//  Menual
//
//  Created by 정진균 on 2022/10/15.
//

import UIKit
import Then
import SnapKit

class SectionListHeaderView: UIView {
    
    public var title: String = "2099.99" {
        didSet { setNeedsLayout() }
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppHead(.head_4)
        $0.textColor = Colors.grey.g600
        $0.text = "2099.99"
    }
    
    private let divider = Divider(type: ._2px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g700
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(titleLabel)
        addSubview(divider)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview()
        }
        
        divider.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(2)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.text = title
    }
}
