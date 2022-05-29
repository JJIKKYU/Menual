//
//  TabsCell.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import UIKit
import Then
import SnapKit

enum TabsCellStatus {
    case active
    case inactive
    case pressed
}

class TabsCell: UICollectionViewCell {
    var tabsCellStatus: TabsCellStatus = .active {
        didSet { setNeedsLayout() }
    }
    
    private let tabsIconView = TabsIconView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tabsIconStep = .step1
        $0.tabsIconStatus = .active
    }
    
    private let tabsText = TabsText().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.number = "99"
        $0.title = "TXT"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        setViews()
        // 여기서 init 진행
    }
 
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setViews() {
        AppCorner(._4pt)
        
        addSubview(tabsIconView)
        addSubview(tabsText)
        
        tabsIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.width.equalTo(15)
        }
        
        tabsText.snp.makeConstraints { make in
            make.leading.equalTo(tabsIconView.snp.trailing).offset(9)
            make.centerY.equalToSuperview()
            make.height.equalTo(29)
            make.trailing.equalToSuperview().inset(14)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch tabsCellStatus {
        case .active:
            backgroundColor = Colors.tint.main.v400
            tabsIconView.tabsIconStatus = .active
            tabsText.numberLabel.textColor = Colors.grey.g800
            tabsText.titleLabel.textColor = Colors.grey.g800
        case .inactive:
            backgroundColor = Colors.grey.g800
            tabsIconView.tabsIconStatus = .inactive
            tabsText.numberLabel.textColor = Colors.tint.main.v400
            tabsText.titleLabel.textColor = Colors.tint.main.v400
        case .pressed:
            backgroundColor = Colors.grey.g700
            tabsIconView.tabsIconStatus = .inactive
            tabsText.numberLabel.textColor = Colors.tint.main.v400
            tabsText.titleLabel.textColor = Colors.tint.main.v400
        }
    }
}
