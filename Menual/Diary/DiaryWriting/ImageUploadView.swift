//
//  ImageUploadView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import UIKit
import Then
import SnapKit

class ImageUploadView: UIView {
    
    var image: UIImage? {
        didSet { setNeedsLayout() }
    }
    
    let uploadedImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
    }
    
    let uploadBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("", for: .normal)
        $0.backgroundColor = .clear
    }
    
    private let centerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let placeHolderImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Asset._24px.picture.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g700
    }
    
    private let placeHolderTextLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.text = "사진 추가"
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = Colors.grey.g800.withAlphaComponent(0.4)
        addSubview(centerView)
        addSubview(uploadBtn)
        addSubview(uploadedImageView)
        
        centerView.addSubview(placeHolderImageView)
        centerView.addSubview(placeHolderTextLabel)
        
        placeHolderImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        placeHolderTextLabel.snp.makeConstraints { make in
            make.leading.equalTo(placeHolderImageView.snp.trailing).offset(4)
            make.width.equalTo(47)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        centerView.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(24)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        uploadBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    
        uploadedImageView.snp.makeConstraints { make in
            make.leading.width.top.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let image = image {
            print("DiaryWriting :: ImageUploadView :: image!")
            uploadedImageView.image = image
            uploadedImageView.isHidden = false
        } else {
            uploadedImageView.image = UIImage()
            uploadedImageView.isHidden = true
        }
    }

}
