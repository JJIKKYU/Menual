//
//  MenuComponentButton.swift
//  Menual
//
//  Created by 정진균 on 2022/12/28.
//

import UIKit
import Then
import SnapKit

public class MenuComponentButton: UIButton {
    var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var leftUIImage: UIImage? {
        didSet { setNeedsLayout() }
    }
    
    private let leftImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Asset._24px.lock.image.withRenderingMode(.alwaysTemplate)
        $0.contentMode = .scaleAspectFit
        $0.tintColor = Colors.grey.g600
    }
    
    private let titleCustomLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "메뉴얼 숨기기"
        $0.font = UIFont.AppBodyOnlyFont(.body_3)
        $0.textColor = Colors.grey.g200
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        print("MenuComponentButton :: init!")
        setViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setViews() {
        addSubview(leftImage)
        addSubview(titleCustomLabel)
        
        leftImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleCustomLabel.snp.makeConstraints { make in
            make.leading.equalTo(leftImage.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        titleCustomLabel.text = title
        if let leftUIImage = leftUIImage {
            leftImage.image = leftUIImage
        }
    }
}
