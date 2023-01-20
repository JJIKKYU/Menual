//
//  MomentsTag.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import UIKit
import SnapKit
import Then
import MenualUtil

public class MomentsTag: UIView {
    
    public var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var titleLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppHead(.head_2)
        $0.textColor = Colors.tint.main.v100
    }

    public init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = Colors.tint.main.v800
        addSubview(titleLabel)
        AppCorner(._2pt)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.top.equalToSuperview()
        }
        titleLabel.sizeToFit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.text = title
    }

}
