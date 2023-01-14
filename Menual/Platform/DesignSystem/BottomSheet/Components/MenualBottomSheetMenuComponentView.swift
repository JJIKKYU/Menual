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
    
    public var isHide: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    private let stackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.alignment = .fill
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
    
    public var hideMenuBtn = MenuComponentButton(frame: .zero).then {
        $0.actionName = "hide"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = MenualString.menu_button_lock
        $0.leftUIImage = Asset._24px.lock.image.withRenderingMode(.alwaysTemplate)
    }
    
    public var editMenuBtn = MenuComponentButton(frame: .zero).then {
        $0.actionName = "edit"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = MenualString.menu_button_edit
        $0.leftUIImage = Asset._24px.modify.image.withRenderingMode(.alwaysTemplate)
    }
    
    public var deleteMenuBtn = MenuComponentButton(frame: .zero).then {
        $0.actionName = "delete"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = MenualString.menu_button_delete
        $0.leftUIImage = Asset._24px.delete.image.withRenderingMode(.alwaysTemplate)
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
        
        deleteMenuBtn.imageView?.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        deleteMenuBtn.titleLabel?.snp.makeConstraints({ make in
            make.leading.equalToSuperview()
        })
        
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
        print("DiaryBottomSheet :: Hide \(isHide)")
        
        switch isHide {
        case false:
            hideMenuBtn.title = MenualString.menu_button_lock
            hideMenuBtn.leftUIImage = Asset._24px.lock.image.withRenderingMode(.alwaysTemplate)
            break

        case true:
            hideMenuBtn.title = MenualString.menu_button_unlock
            hideMenuBtn.leftUIImage = Asset._24px.unlock.image.withRenderingMode(.alwaysTemplate)
            break
        }
    }
}
