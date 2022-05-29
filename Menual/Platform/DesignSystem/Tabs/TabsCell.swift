//
//  TabsCell.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import UIKit
import Then
import SnapKit

class TabsCell: UICollectionViewCell {
    private let tabsIconView = TabsIconView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
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
        addSubview(tabsIconView)
        
        tabsIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(1)
            make.width.equalTo(20)
            make.height.equalTo(50)
            make.top.equalToSuperview().inset(1)
        }
    }
}
