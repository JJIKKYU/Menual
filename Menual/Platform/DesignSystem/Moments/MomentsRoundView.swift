//
//  MomentsRoundView.swift
//  Menual
//
//  Created by 정진균 on 2022/03/17.
//

import UIKit
import SnapKit

class MomentsRoundView: UIView {
    
    var text: String = "Hi" {
        didSet { setNeedsLayout() }
    }
    
    var image: UIImage = UIImage(systemName: "circle")! {
        didSet { setNeedsLayout() }
    }
    
    private lazy var imageView = UIImageView()
    private lazy var textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("momentsRoundView! init")
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        print("layoutsubviews")
        imageView.image = image
        textLabel.text = text
    }
    
    func layout() {
        addSubview(imageView)
        addSubview(textLabel)
        
        backgroundColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1)
        AppCorner(.large)
        AppShadow(.shadow_1)
        
        imageView.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
        
        textLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }
    }
}
