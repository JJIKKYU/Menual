//
//  MenualProgressView.swift
//  
//
//  Created by 정진균 on 2023/03/01.
//

import UIKit
import SnapKit
import Then

public class MenualProgressView: UIView {
    
    public var progressValue: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    private let progressIconView = ProgressIconView(frame: .zero)
    private let slider = UISlider(frame: .zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let value = progressValue as NSNumber
        progressIconView.updateAnimateProgress(value)
        
    }
    
    func setViews() {
        addSubview(progressIconView)
        backgroundColor = Colors.background.withAlphaComponent(0.6)

        progressIconView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(71)
            make.height.equalTo(67)
        }
    }
}
