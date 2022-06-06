//
//  DividerCell.swift
//  Menual
//
//  Created by 정진균 on 2022/06/06.
//

import UIKit
import SnapKit
import Then

class DividerCell: UICollectionViewCell {
    let dividerView = Divider(type: .year).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .red
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
        addSubview(dividerView)
        
        dividerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
