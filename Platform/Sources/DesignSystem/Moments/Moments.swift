//
//  Moments.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import UIKit
import SnapKit
import Then

class Moments: UIView {
    
    var tagTitle: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var momentsTitle: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var icon: String = "" {
        didSet { setNeedsLayout() }
    }
    
    private let momentsText = MomentsText().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let momentsImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.image = Asset._120px.tea.image
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(momentsText)
        addSubview(momentsImageView)
        backgroundColor = Colors.tint.main.v400
        AppCorner(._4pt)
        
        momentsImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(120)
        }
        
        momentsText.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(21)
            make.trailing.equalTo(momentsImageView.snp.leading).inset(8)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        momentsText.tagTitle = tagTitle
        momentsText.momentsTitle = momentsTitle
        if icon.isEmpty {
            momentsImageView.image = ImageAsset(name: "120px/book/open").image
        } else {
            momentsImageView.image = ImageAsset(name: "\(icon)").image
        }
    }

}
