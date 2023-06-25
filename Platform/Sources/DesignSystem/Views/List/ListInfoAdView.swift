//
//  ListInfoAdView.swift
//  
//
//  Created by 정진균 on 2023/05/20.
//

import UIKit
import MenualUtil
import Then

public class ListInfoAdView: UIView {
    
    public var adText: String = "스폰서 노출 영역" {
        didSet { setNeedsLayout() }
    }
    
    private let adTextLabel: UILabel = .init().then {
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g600
        $0.numberOfLines = 1
        $0.text = "스폰서 노출 영역"
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        adTextLabel.text = adText
    }
    
    func setViews() {
        addSubview(adTextLabel)

        adTextLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}
