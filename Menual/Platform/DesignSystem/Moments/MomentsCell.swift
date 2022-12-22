//
//  MomentsCell.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import UIKit
import Then
import SnapKit

class MomentsCell: UICollectionViewCell {
    
    var tagTitle: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var momentsTitle: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var icon: String = "" {
        didSet { setNeedsLayout() }
    }
    
    private let momentsView = Moments().then {
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
        addSubview(momentsView)
        
        momentsView.snp.makeConstraints { make in
            make.leading.top.bottom.trailing.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        momentsView.tagTitle = tagTitle
        momentsView.momentsTitle = momentsTitle
        momentsView.icon = icon
    }
}
