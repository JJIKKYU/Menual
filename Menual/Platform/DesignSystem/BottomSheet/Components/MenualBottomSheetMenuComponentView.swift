//
//  MenualBottomSheetMenuComponentView.swift
//  Menual
//
//  Created by 정진균 on 2022/09/10.
//

import UIKit
import SnapKit
import Then

class MenualBottomSheetMenuComponentView: UIView {
    
    enum MenuComponent {
        case none
        case hide
        case edit
        case delete
    }
    
    private let stackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fill
        $0.spacing = 20
    }
    
    private let divider1 = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g700
    }
    
    private let divider2 = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g700
    }
    
    public var hideMenuBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("메뉴얼 숨기기", for: .normal)
        $0.setTitleColor(Colors.grey.g200, for: .normal)
        $0.setImage(Asset._24px.lock.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.titleLabel?.font = UIFont.AppBodyOnlyFont(.body_3)
        
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        
        $0.marginImageWithText(margin: 8)
    }
    
    public var editMenuBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("수정하기", for: .normal)
        $0.setTitleColor(Colors.grey.g200, for: .normal)
        $0.setImage(Asset._24px.modify.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.titleLabel?.font = UIFont.AppBodyOnlyFont(.body_3)
        
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        
        $0.marginImageWithText(margin: 8)
        
    }
    
    public var deleteMenuBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("삭제하기", for: .normal)
        $0.setTitleColor(Colors.grey.g200, for: .normal)
        $0.setImage(Asset._24px.delete.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.titleLabel?.font = UIFont.AppBodyOnlyFont(.body_3)
        
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        
        $0.marginImageWithText(margin: 8)
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(hideMenuBtn)
        stackView.addArrangedSubview(divider1)
        stackView.addArrangedSubview(editMenuBtn)
        stackView.addArrangedSubview(divider2)
        stackView.addArrangedSubview(deleteMenuBtn)
        
        stackView.snp.makeConstraints { make in
            make.leading.top.width.bottom.equalToSuperview()
        }
        
        divider1.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(1)
        }
        
        divider2.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
