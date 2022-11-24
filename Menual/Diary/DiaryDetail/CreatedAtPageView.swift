//
//  CreatedAtPageView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import UIKit
import SnapKit
import Then

class CreatedAtPageView: UIView {
    
    var createdAt: String = "2022.99.99" {
        didSet { setNeedsLayout() }
    }
    
    var page: String = "999" {
        didSet { setNeedsLayout() }
    }
    
    private let createdAtLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
    }
    
    private let divider = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g600
    }
    
    private let pageLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(createdAtLabel)
        addSubview(divider)
        addSubview(pageLabel)
        
        createdAtLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalTo(createdAtLabel.snp.trailing).offset(8)
            make.width.equalTo(1)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        pageLabel.snp.makeConstraints { make in
            make.leading.equalTo(divider.snp.trailing).offset(8)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        createdAtLabel.text = createdAt
        pageLabel.text = "P.\(page)"
    }

}
