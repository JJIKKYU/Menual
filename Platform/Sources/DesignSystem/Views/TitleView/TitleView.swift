//
//  TitleView.swift
//  Menual
//
//  Created by 정진균 on 2022/03/27.
//

import UIKit
import SnapKit
import Then

class TitleView: UIView {
    var title: String = "TITLE VIEW" {
        didSet { setNeedsLayout() }
    }

    var rightTitle: String = "Right Btn" {
        didSet { setNeedsLayout() }
    }
    
    lazy var titleButton = UIButton().then {
        $0.titleLabel?.font = UIFont.AppTitle(.title_4)
        $0.setTitle("TITLE VIEW", for: .normal)
        $0.setTitleColor(Colors.grey.g100, for: .normal)
    }
    
    lazy var rightButton = UIButton().then {
        $0.setTitle("Right Btn", for: .normal)
        $0.titleLabel?.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.setTitleColor(Colors.grey.g100, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("TitleView! init")
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleButton.setTitle(title, for: .normal)
        rightButton.setTitle(rightTitle, for: .normal)
        
        print("layoutsubviews")
    }
    
    func layout() {
//        addSubview(imageView)
        addSubview(titleButton)
        addSubview(rightButton)
        
        titleButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
        
        rightButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
    }
}
