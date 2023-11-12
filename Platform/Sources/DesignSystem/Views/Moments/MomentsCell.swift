//
//  MomentsCell.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import UIKit
import Then
import SnapKit

public class MomentsCell: UICollectionViewCell {
    
    public var tagTitle: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var momentsTitle: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var icon: String = "" {
        didSet { setNeedsLayout() }
    }
    
    private let momentsView = Moments().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        setViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setViews() {
        addSubview(momentsView)
        
        momentsView.snp.makeConstraints { make in
            make.leading.top.bottom.trailing.equalToSuperview()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        momentsView.tagTitle = tagTitle
        momentsView.momentsTitle = momentsTitle
        momentsView.icon = icon
    }
}
