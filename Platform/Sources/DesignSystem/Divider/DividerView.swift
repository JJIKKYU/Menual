//
//  DividerView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/06.
//

import UIKit
import Then
import SnapKit

class DividerView: UICollectionReusableView {
    
    var date: String = "2099" {
        didSet { setNeedsLayout() }
    }
    
    let divider = Divider(type: .year).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

     override init(frame: CGRect) {
         super.init(frame: frame)

         addSubview(divider)
         divider.snp.makeConstraints { make in
             make.leading.equalToSuperview()
             make.top.equalToSuperview()
             make.trailing.equalToSuperview()
             make.bottom.equalToSuperview()
         }
         divider.dateTitle = "2099"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        divider.dateTitle = date
    }
}
