//
//  IndicatorView.swift
//  Menual
//
//  Created by 정진균 on 2022/10/15.
//

import UIKit
import SnapKit
import Then

class IndicatorView: UIView {
    
    public var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    private let backgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g800
        $0.layer.cornerRadius = 10
    }
    
    private let indicatorLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "1234.12"
        $0.textAlignment = .center
        $0.textColor = Colors.grey.g500
        // TOOD: - 폰트
        $0.font = UIFont.AppTitle(.title_6).withSize(10)

    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = .clear
        addSubview(backgroundView)
        backgroundView.addSubview(indicatorLabel)
        
        backgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        indicatorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 56, height: 20)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        indicatorLabel.text = title
    }
}
