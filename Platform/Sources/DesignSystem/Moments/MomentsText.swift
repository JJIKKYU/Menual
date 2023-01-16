//
//  MomentsText.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import UIKit
import SnapKit
import Then
import DesignSystem

class MomentsText: UIView {
    
    var tagTitle: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var momentsTitle: String = "" {
        didSet { setNeedsLayout() }
    }
    
    private let momentsTagView = MomentsTag().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var momentsTitleLabel = UILabel().then {
        // $0.lineBreakStrategy = .hangulWordPriority
        $0.lineBreakMode = .byWordWrapping
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 2
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = Colors.grey.g100
        $0.text = momentsTitle
        $0.adjustsFontSizeToFitWidth = false
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(momentsTagView)
        addSubview(momentsTitleLabel)
        
        momentsTagView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        momentsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(momentsTagView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        momentsTagView.title = tagTitle
        momentsTitleLabel.text = momentsTitle
        momentsTitleLabel.setLineHeight(lineHeight: 1.28)
    }
}
