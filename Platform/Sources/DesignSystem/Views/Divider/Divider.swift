//
//  Divider.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import UIKit
import SnapKit
import Then

public enum DividerType {
    case _2px
    case _1px
    case year
}

public class Divider: UIView {
    
    public var type: DividerType = ._1px {
        didSet { setNeedsLayout() }
    }
    
    public var dateTitle: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var dateTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppHead(.head_1)
        $0.textColor = Colors.tint.main.v700
        $0.transform = CGAffineTransform(rotationAngle: CGFloat(Double(-90) * .pi/180))
    }

    public init(type: DividerType) {
        self.type = type
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(dateTitleLabel)
        
        dateTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        switch type {
        case ._1px:
            backgroundColor = Colors.grey.g800
            break
        case ._2px:
            backgroundColor = Colors.grey.g800
            break
        case .year:
            dateTitleLabel.text = dateTitle
            backgroundColor = .clear
            layer.borderWidth = 1.0
            layer.borderColor = Colors.tint.main.v700.cgColor
            AppCorner(._4pt)
            break
        }
    }

}
