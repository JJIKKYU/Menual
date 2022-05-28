//
//  FAB.swift
//  Menual
//
//  Created by 정진균 on 2022/05/28.
//

import Foundation
import Then
import SnapKit

enum FABType {
    case primary
    case secondary
}

enum FABStatus {
    case default_
    case pressed
}

class FAB: UIButton {
    var fabType: FABType = .primary {
        didSet { setNeedsLayout() }
    }
    
    var fabStatus: FABStatus = .default_ {
        didSet { setNeedsLayout() }
    }
    
    private let fabIconImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.image = Asset._24px.write.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g800
    }
    
    override open var isHighlighted: Bool {
        didSet {
            fabStatus = isHighlighted ? .pressed : .default_
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    convenience init(fabType: FABType, fabStatus: FABStatus) {
        self.init()
        self.fabType = fabType
        self.fabStatus = fabStatus
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = Colors.tint.sub.n400
        layer.cornerRadius = 28
        AppShadow(.shadow_4)
        
        addSubview(fabIconImageView)
        
        fabIconImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch fabType {
        case .primary:
            fabIconImageView.image = Asset._24px.write.image.withRenderingMode(.alwaysTemplate)
            fabIconImageView.tintColor = Colors.grey.g800
            
            switch fabStatus {
            case .default_:
                backgroundColor = Colors.tint.sub.n400
            case .pressed:
                backgroundColor = Colors.tint.sub.n600
            }
            
        case .secondary:
            fabIconImageView.image = Asset._24px.Arrow.Up.big.image.withRenderingMode(.alwaysTemplate)
            fabIconImageView.tintColor = Colors.grey.g400
            
            switch fabStatus {
            case .default_:
                backgroundColor = Colors.grey.g800
            case .pressed:
                backgroundColor = Colors.grey.g700
            }
        }
    }
}
