//
//  MomentsEmptyView.swift
//  Menual
//
//  Created by 정진균 on 2022/11/19.
//

import UIKit
import SnapKit
import Then

class MomentsEmptyView: UIView {
    
    let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_2)
        $0.textColor = Colors.grey.g200
        $0.text = "메뉴얼을 작성하시면\n다양한 컨텐츠를 확인할 수 있어요."
        $0.setLineSpacing(lineSpacing: 3)
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    let writingBtn = UIButton().then { (btn: UIButton) in
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("메뉴얼 작성하기", for: .normal)
        btn.titleLabel?.font = UIFont.AppBodyOnlyFont(.body_2)
        btn.layer.borderColor = Colors.grey.g200.cgColor
        btn.layer.cornerRadius = 4
        btn.layer.borderWidth = 1
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
        addSubview(writingBtn)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        writingBtn.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(26)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
