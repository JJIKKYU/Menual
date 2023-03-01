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
    private let progressLabel = UILabel(frame: .zero)
    
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
        addSubview(progressLabel)
        backgroundColor = Colors.background.withAlphaComponent(0.6)
        
        progressLabel.do {
            $0.numberOfLines = 1
            $0.text = "메뉴얼을 가져오고 있어요..."
            $0.textColor = Colors.grey.g200
            $0.font = UIFont.AppBodyOnlyFont(.body_3)
        }

        progressIconView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(71)
            make.height.equalTo(67)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(progressIconView.snp.bottom).offset(14)
        }
    }
}
